import Foundation
import MapCore
@_spi(MapConductorDriver) import MapConductorCore

/// このドライバーが地図に載せるレイヤ一式と、その重ね順。
///
/// ## なぜレイヤを 1 箇所で持つのか
///
/// Open Mobile Maps は「オーバーレイ 1 つ = ネイティブオブジェクト 1 つ」ではなく
/// 「**種別ごとに 1 枚のレイヤ**があり、そこへ要素のリストを流し込む」形の SDK である
/// （MapLibre の GeoJSON ソースに近い）。レンダラが個別にレイヤを作ると重ね順が
/// 生成順に依存して不定になるので、ここでまとめて作り、索引を割り当てる。
///
/// ## 重ね順（下から）
///
/// ```
/// 地図デザイン → ラスターレイヤ → グラウンドイメージ → ポリゴン塗り → ポリゴン輪郭
///   → 円の塗り → 円の輪郭 → ポリライン → マーカーのタイル → マーカー
/// ```
///
/// これは全プロバイダ共通の帯の順（``OverlayBand``）。ラスターとグラウンドイメージは
/// 以前は同じ枠に空いた索引から詰めていたので、送り直すと上下が入れ替わった。
/// マーカーのタイルもラスターの経路で載るため、ポリゴン等より下に描かれていた。
/// 今は帯ごとに索引の区間を分けている（``insertBelowOverlays(_:key:on:)``）。
///
/// 他プロバイダのクリックのカスケード（marker → circle → groundImage → polyline →
/// polygon → map）と**上下が逆に見える**が、これは正しい。カスケードは「上にあるものから
/// 順に当たり判定する」ので、描画の重ね順を上から読むとカスケード順に一致する。
///
/// ## この SDK のレイヤ API には罠が 2 つある
///
/// **1. `insertLayer(at:at:)` は挿入ではなく上書きである。**
/// `MapScene` はレイヤを「索引 → レイヤ」の map で持っていて、その索引に居たレイヤを
/// `onRemoved()` して置き換える。地図デザインを索引 0 に入れると、索引 0 に居た
/// **ポリゴン塗りレイヤが黙って外れる**。症状は「円は塗れるのにポリゴンだけ塗れない」で、
/// 例外もログも出ない。だから索引は ``designIndex`` / ``belowIndexFirst`` /
/// ``fixedIndexFirst`` に分けて**衝突させない**。
///
/// **2. `asLayerInterface()` は呼ぶたびに別のオブジェクトを返す。**
/// `insertLayer(below:below: polygonFillLayer.asLayerInterface())` は「そんなレイヤは無い」で
/// 落ちる。`removeLayer` も黙って何も外さない。載せたときの値を持っておいて、それを渡すこと。
///
/// android-for-openmobilemaps の `OpenMobileMapsLayers.kt` と同じ構造・同じ索引。
@MainActor
final class OpenMobileMapsLayers {
    /// 地図デザイン。一番下。
    private static let designIndex: Int32 = 0

    /// ラスターレイヤ・グラウンドイメージ。地図デザインとオーバーレイ群の間。
    private static let belowIndexFirst: Int32 = 1

    /// 固定のオーバーレイ 6 種。下の枠を使い切らないよう十分離す。
    private static let fixedIndexFirst: Int32 = 1000

    /// 固定レイヤどうしの間隔。間にマーカーのタイルを入れるため空けておく。
    private static let fixedIndexStride: Int32 = 100

    /// マーカーのタイル（ラスターの経路で載る）。ポリラインの上・マーカーのアイコンの下。
    /// 固定レイヤの並び（``fixedLayers``）でポリラインは 4 番目、アイコンは 5 番目。
    private static let markerTileIndexFirst: Int32 = fixedIndexFirst + 4 * fixedIndexStride + fixedIndexStride / 2

    let polygonFillLayer = MCPolygonLayerInterface.create()
    let polygonOutlineLayer = MCLineLayerInterface.create()
    let circleFillLayer = MCPolygonLayerInterface.create()
    let circleOutlineLayer = MCLineLayerInterface.create()
    let polylineLayer = MCLineLayerInterface.create()
    let iconLayer = MCIconLayerInterface.create()

    /// クラスタリング等の strategy 描画（`MarkerRenderingSupport`）専用のアイコンレイヤ。
    /// レンダラの ``OpenMobileMapsMarkerOverlayRenderer/applyIcons()`` は自分の
    /// markerManager の**全量**を `setIcons` で流し込むため、通常マーカーとレイヤを
    /// 共有すると互いに上書きし合う。1 枚分けて一番上に置く。
    let strategyIconLayer = MCIconLayerInterface.create()

    /// 地図デザインのレイヤ。差し替え時に外すため、**載せた値そのもの**を持っておく。
    private var designLayer: MCLayerInterface?

    /// ラスター / グラウンドイメージ / マーカーのタイルが使っている索引。帯ごとに別の区間を持つ。
    private var slotIndices: [ObjectIdentifier: Int32] = [:]
    /// 帯ごとの、外したレイヤの索引（使い回さないと張り替えを繰り返すうちに区間が尽きる）と次の索引。
    private var freeSlots: [OverlayBand: [Int32]] = [:]
    private var nextSlot: [OverlayBand: Int32] = [:]

    /// `asLayerInterface()` の戻りを**一度だけ**取って持っておく（罠 2）。
    private lazy var fixedLayers: [MCLayerInterface] = [
        polygonFillLayer?.asLayerInterface(),
        polygonOutlineLayer?.asLayerInterface(),
        circleFillLayer?.asLayerInterface(),
        circleOutlineLayer?.asLayerInterface(),
        polylineLayer?.asLayerInterface(),
        iconLayer?.asLayerInterface(),
        strategyIconLayer?.asLayerInterface(),
    ].compactMap { $0 }

    /// 固定レイヤを地図へ載せる。
    ///
    /// ## クリックは SDK に取らせない
    ///
    /// どのレイヤも `setLayerClickable(false)` にする。当たり判定はコアの Manager が
    /// 地理座標で行う（そうしないとプロバイダごとに結果が変わる）ので、SDK 側の
    /// ヒットテストが先に食べてしまうと `clickable = false` の透過もカスケードの順序も
    /// 効かなくなる。**ここを消すと「ポリゴンをタップしても下のマーカーに当たらない」
    /// という形で壊れる。**
    func attach(to map: MCMapInterface) {
        polygonFillLayer?.setLayerClickable(false)
        circleFillLayer?.setLayerClickable(false)
        polygonOutlineLayer?.setLayerClickable(false)
        circleOutlineLayer?.setLayerClickable(false)
        polylineLayer?.setLayerClickable(false)
        iconLayer?.setLayerClickable(false)
        strategyIconLayer?.setLayerClickable(false)

        for (offset, layer) in fixedLayers.enumerated() {
            map.insertLayer(at: layer, at: Self.fixedIndexFirst + Int32(offset) * Self.fixedIndexStride)
        }
    }

    /// 地図デザインのレイヤを差し替える。
    func setDesignLayer(_ layer: MCLayerInterface?, on map: MCMapInterface) {
        if let designLayer { map.removeLayer(designLayer) }
        designLayer = layer
        guard let layer else { return }
        map.insertLayer(at: layer, at: Self.designIndex)
    }

    /// 帯ごとの索引の区間（下端）。ラスター < グラウンドイメージ < （固定のオーバーレイ）
    /// < マーカーのタイル（ポリラインとマーカーのアイコンの間）。
    private static func slotBase(_ band: OverlayBand) -> Int32 {
        switch band {
        case .rasterLayer: return belowIndexFirst
        case .groundImage: return belowIndexFirst + 500
        case .marker: return markerTileIndexFirst
        // ポリゴンのタイル（feat/polygon-tiling）はポリゴン塗りの直前に入れる。
        case .polygon: return fixedIndexFirst - fixedIndexStride / 2
        case .circle: return fixedIndexFirst + 2 * fixedIndexStride - fixedIndexStride / 2
        case .polyline: return fixedIndexFirst + 4 * fixedIndexStride - fixedIndexStride / 2
        }
    }

    /// ラスターレイヤ／グラウンドイメージ／マーカーのタイルを、帯の区間へ入れる。
    ///
    /// 以前はラスターとグラウンドイメージが同じ区間を空いた索引から詰めていたので、
    /// 送り直すと上下が入れ替わり、マーカーのタイルもポリゴン等より下に描かれていた。
    /// 帯ごとに区間を分ければ、追加・送り直しの順に関わらず帯の順になる。
    /// 既に載っているレイヤは動かさない（OMM では一度外したレイヤを入れ直すと描かれなくなる。実機）。
    /// 帯の中の zIndex は反映しない（従来どおり。区間の中は空いた索引の順）。
    ///
    /// - Returns: 外すときに ``remove(_:from:)`` へ渡す値。
    ///   **別途 `asLayerInterface()` を呼び直さないこと。**
    @discardableResult
    func insertBelowOverlays(
        _ layer: MCLayerInterface,
        key: OverlayStackKey,
        on map: MCMapInterface
    ) -> MCLayerInterface {
        let band = key.band
        let index: Int32
        if var free = freeSlots[band], !free.isEmpty {
            index = free.removeFirst()
            freeSlots[band] = free
        } else {
            index = Self.slotBase(band) + (nextSlot[band] ?? 0)
            nextSlot[band] = (nextSlot[band] ?? 0) + 1
        }
        slotIndices[ObjectIdentifier(layer)] = index
        slotBands[ObjectIdentifier(layer)] = band
        map.insertLayer(at: layer, at: index)
        return layer
    }

    private var slotBands: [ObjectIdentifier: OverlayBand] = [:]

    func remove(_ layer: MCLayerInterface, from map: MCMapInterface) {
        let id = ObjectIdentifier(layer)
        if let index = slotIndices.removeValue(forKey: id), let band = slotBands.removeValue(forKey: id) {
            freeSlots[band, default: []].append(index)
            freeSlots[band]?.sort()
        }
        map.removeLayer(layer)
    }

    func clearAll() {
        polygonFillLayer?.clear()
        polygonOutlineLayer?.clear()
        circleFillLayer?.clear()
        circleOutlineLayer?.clear()
        polylineLayer?.clear()
        iconLayer?.clear()
        strategyIconLayer?.clear()
    }
}
