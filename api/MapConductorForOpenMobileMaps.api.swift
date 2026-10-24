import Combine
import CoreGraphics
import DjinniSupport
import Foundation
import MapConductorCore
import MapCore
import QuartzCore
import Swift
import SwiftUI
import UIKit
import _Concurrency
import _StringProcessing
import _SwiftConcurrencyShims
public enum OpenMobileMapsCapabilities {
  public static func declare(into registry: MapConductorCore::MutableMapServiceRegistry)
}
public protocol OpenMobileMapsMapDesignTypeProtocol : MapConductorCore::MapDesignTypeProtocol where Self.Identifier == Swift::String {
  var tileUrlTemplate: Swift::String { get }
  var tileSize: Swift::Int { get }
}
extension MapConductorForOpenMobileMaps::OpenMobileMapsMapDesignTypeProtocol {
  public var tileSize: Swift::Int {
    get
  }
}
public struct OpenMobileMapsDesign : MapConductorForOpenMobileMaps::OpenMobileMapsMapDesignTypeProtocol, Swift::Equatable {
  public let id: Swift::String
  public let tileUrlTemplate: Swift::String
  public let tileSize: Swift::Int
  public let attributionRules: [MapConductorCore::AttributionRule]
  public init(id: Swift::String, tileUrlTemplate: Swift::String, tileSize: Swift::Int = 256, attributionRules: [MapConductorCore::AttributionRule] = [])
  public func getValue() -> Swift::String
  public static func == (lhs: MapConductorForOpenMobileMaps::OpenMobileMapsDesign, rhs: MapConductorForOpenMobileMaps::OpenMobileMapsDesign) -> Swift::Bool
  public static let none: MapConductorForOpenMobileMaps::OpenMobileMapsDesign
  public static let openStreetMap: MapConductorForOpenMobileMaps::OpenMobileMapsDesign
  public static let openStreetMapJapan: MapConductorForOpenMobileMaps::OpenMobileMapsDesign
  public static let openTopoMap: MapConductorForOpenMobileMaps::OpenMobileMapsDesign
  public typealias Identifier = Swift::String
}
@objc @_inheritsConvenienceInitializers @_Concurrency::MainActor @preconcurrency final public class OpenMobileMapsMapSurface : UIKit::UIView {
  @_Concurrency::MainActor @preconcurrency final public var mapView: MapCore::MCMapView? {
    get
  }
  @_Concurrency::MainActor @preconcurrency final public var visualTilt: Swift::Double {
    get
    set
  }
  @_Concurrency::MainActor @preconcurrency weak final public var overlayContainer: UIKit::UIView? {
    get
    set
  }
  @_Concurrency::MainActor @preconcurrency final public func attach(mapView: MapCore::MCMapView)
  @_Concurrency::MainActor @preconcurrency @objc override final public func layoutSubviews()
  @_Concurrency::MainActor @preconcurrency final public func fromInnerToSurface(_ point: CoreFoundation::CGPoint) -> CoreFoundation::CGPoint
  @_Concurrency::MainActor @preconcurrency final public func fromSurfaceToInner(_ point: CoreFoundation::CGPoint) -> CoreFoundation::CGPoint?
  @_Concurrency::MainActor @preconcurrency @objc override dynamic public init(frame: CoreFoundation::CGRect)
  @_Concurrency::MainActor @preconcurrency @objc required dynamic public init?(coder: Foundation::NSCoder)
  @objc deinit
}
@_Concurrency::MainActor @preconcurrency public struct OpenMobileMapsMapView : SwiftUICore::View {
  @_Concurrency::MainActor @preconcurrency public init(state: MapConductorForOpenMobileMaps::OpenMobileMapsViewState, cameraRestriction: MapConductorCore::CameraRestriction? = nil, onMapLoaded: MapConductorCore::OnMapLoadedHandler<MapConductorForOpenMobileMaps::OpenMobileMapsViewState>? = nil, onMapClick: MapConductorCore::OnMapEventHandler? = nil, onMapLongClick: MapConductorCore::OnMapEventHandler? = nil, onCameraMoveStart: MapConductorCore::OnCameraMoveHandler? = nil, onCameraMove: MapConductorCore::OnCameraMoveHandler? = nil, onCameraMoveEnd: MapConductorCore::OnCameraMoveHandler? = nil, sdkInitialize: (() -> Swift::Void)? = nil, style: (any MapConductorCore::MapViewStyle)? = nil, onStyleDiagnostics: (([Swift::String]) -> Swift::Void)? = nil, @MapConductorCore::MapViewContentBuilder content: @escaping () -> MapConductorCore::MapViewContent = { MapViewContent() })
  @_Concurrency::MainActor @preconcurrency public var body: some SwiftUICore::View {
    get
  }
  public typealias Body = @_opaqueReturnTypeOf("$s29MapConductorForOpenMobileMaps0defA4ViewV4bodyQrvp", 0) __
}
@_Concurrency::MainActor public func createOpenMobileMapsViewController(holder: MapConductorForOpenMobileMaps::OpenMobileMapsMapViewHolder, loaders: [any MapCoreSharedModule::MCLoaderInterface], serviceRegistry: MapConductorCore::MutableMapServiceRegistry? = nil) -> MapConductorForOpenMobileMaps::OpenMobileMapsMapViewController
@_hasMissingDesignatedInitializers @_Concurrency::MainActor final public class OpenMobileMapsMapViewController : MapConductorCore::MapViewControllerProtocol {
  @_Concurrency::MainActor final public let holder: MapConductorCore::AnyMapViewHolder
  @_Concurrency::MainActor final public let coroutine: MapConductorCore::CoroutineScope
  @_Concurrency::MainActor final public let overlayControllers: MapConductorCore::OverlayControllerRegistry
  @_Concurrency::MainActor final public func moveCamera(position: MapConductorCore::MapCameraPosition)
  @_Concurrency::MainActor final public func animateCamera(position: MapConductorCore::MapCameraPosition, duration: MapConductorCore::Long)
  @_Concurrency::MainActor final public func fitBounds(bounds: MapConductorCore::GeoRectBounds, padding: Swift::Int)
  @_Concurrency::MainActor final public func applyUISettings(_ settings: MapConductorCore::MapUISettings)
  @_Concurrency::MainActor final public func setMapDesignType(_ value: any MapConductorForOpenMobileMaps::OpenMobileMapsMapDesignTypeProtocol)
  @_Concurrency::MainActor final public func declareCapabilities(into registry: MapConductorCore::MutableMapServiceRegistry)
  @_Concurrency::MainActor final public func clearOverlays() async
  @_Concurrency::MainActor final public func destroy()
  @_Concurrency::MainActor final public func setCameraMoveStartListener(listener: MapConductorCore::OnCameraMoveHandler?)
  @_Concurrency::MainActor final public func setCameraMoveListener(listener: MapConductorCore::OnCameraMoveHandler?)
  @_Concurrency::MainActor final public func setCameraMoveEndListener(listener: MapConductorCore::OnCameraMoveHandler?)
  @_Concurrency::MainActor final public func setMapClickListener(listener: MapConductorCore::OnMapEventHandler?)
  @_Concurrency::MainActor final public func setMapLongClickListener(listener: MapConductorCore::OnMapEventHandler?)
  @_Concurrency::MainActor final public func setMapInitializedListener(listener: MapConductorCore::OnMapInitializedHandler?)
  @objc deinit
}
@_hasMissingDesignatedInitializers @_Concurrency::MainActor final public class OpenMobileMapsMapViewHolder : MapConductorCore::MapViewHolderProtocol {
  @_Concurrency::MainActor final public let mapView: MapConductorForOpenMobileMaps::OpenMobileMapsMapSurface
  @_Concurrency::MainActor final public let map: MapCoreSharedModule::MCMapInterface
  @_Concurrency::MainActor final public func toScreenOffset(position: any MapConductorCore::GeoPointProtocol) -> CoreFoundation::CGPoint?
  @_Concurrency::MainActor final public func fromScreenOffsetSync(offset: CoreFoundation::CGPoint) -> MapConductorCore::GeoPoint?
  public typealias ActualMap = MapCoreSharedModule::MCMapInterface
  public typealias ActualMapView = MapConductorForOpenMobileMaps::OpenMobileMapsMapSurface
  @objc deinit
}
public typealias OpenMobileMapsActualMarker = MapCoreSharedModule::MCIconInfoInterface
public typealias OpenMobileMapsActualPolyline = [MapCoreSharedModule::MCLineInfoInterface]
public struct OpenMobileMapsActualPolygon {
  public let fills: [MapCoreSharedModule::MCPolygonInfo]
  public let outlines: [MapCoreSharedModule::MCLineInfoInterface]
}
public struct OpenMobileMapsActualCircle {
  public let fills: [MapCoreSharedModule::MCPolygonInfo]
  public let outlines: [MapCoreSharedModule::MCLineInfoInterface]
}
public struct OpenMobileMapsActualGroundImage {
  public let layer: MapCoreSharedModule::MCTexturedPolygonLayerInterface
  public let layerInterface: any MapCoreSharedModule::MCLayerInterface
}
public struct OpenMobileMapsActualRasterLayer {
  public let layer: MapCoreSharedModule::MCTiled2dMapRasterLayerInterface
  public let layerInterface: any MapCoreSharedModule::MCLayerInterface
}
final public class OpenMobileMapsViewState : MapConductorCore::MapViewState<any MapConductorForOpenMobileMaps::OpenMobileMapsMapDesignTypeProtocol> {
  final public var mapViewHolder: MapConductorForOpenMobileMaps::OpenMobileMapsMapViewHolder? {
    get
  }
  override final public var mapDesignType: any MapConductorForOpenMobileMaps::OpenMobileMapsMapDesignTypeProtocol {
    get
    set
  }
  public init(id: Swift::String = UUID().uuidString, mapDesignType: any MapConductorForOpenMobileMaps::OpenMobileMapsMapDesignTypeProtocol = OpenMobileMapsDesign.openStreetMap, cameraPosition: MapConductorCore::MapCameraPosition = .Default, uiSettings: MapConductorCore::MapUISettings = MapUISettings())
  override final public func getMapViewHolder() -> MapConductorCore::AnyMapViewHolder?
  @objc deinit
}
final public class OpenMobileMapsZoomAltitudeConverter : MapConductorCore::ZoomAltitudeConverterProtocol {
  public static let scaleAtZoom0: Swift::Double
  final public let zoom0Altitude: Swift::Double
  public init(zoom0Altitude: Swift::Double = AbstractZoomAltitudeConverter.defaultZoom0Altitude)
  final public func toUnifiedZoom(_ nativeScale: Swift::Double) -> Swift::Double
  final public func toNativeZoom(_ unifiedZoom: Swift::Double) -> Swift::Double
  final public func zoomLevelToAltitude(zoomLevel: Swift::Double, latitude: Swift::Double, tilt: Swift::Double) -> Swift::Double
  final public func altitudeToZoomLevel(altitude: Swift::Double, latitude: Swift::Double, tilt: Swift::Double) -> Swift::Double
  @objc deinit
}
extension MapConductorForOpenMobileMaps::OpenMobileMapsMapViewController : Swift::Sendable {}
extension MapConductorForOpenMobileMaps::OpenMobileMapsMapView : Swift::Sendable {}
extension MapConductorForOpenMobileMaps::OpenMobileMapsMapViewHolder : Swift::Sendable {}
