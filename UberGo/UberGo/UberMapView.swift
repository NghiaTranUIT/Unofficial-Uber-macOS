//
//  UberMapView.swift
//  UberGo
//
//  Created by Nghia Tran on 6/16/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Mapbox
import MapboxDirections
import RxSwift
import UberGoCore

protocol UberMapViewDelegate: class {
    func uberMapViewTimeEstimateForOriginAnnotation() -> TimeEstimateObj?
}

class UberMapView: MGLMapView {

    // MARK: - Variable
    weak var uberMapDelegate: UberMapViewDelegate?
    fileprivate var viewModel: MapViewModelProtocol!
    fileprivate let disposeBag = DisposeBag()

    // Origin
    fileprivate var originPoint: OriginAnnotation?

    // Destination
    fileprivate var destinationPoint: DestinationAnnotation?

    // Pickup place
    fileprivate var pickupPoint: PickupAnnotation?
    fileprivate var pickupPointSource: MGLShapeSource?
    fileprivate var pickupPointLine: PickupDashedLine?

    // Driver Place
    fileprivate var driverPoint: MGLPointAnnotation?

    // Visible Route
    fileprivate var visibleRoute: MGLPolyline?

    fileprivate var circleSource: MGLShapeSource?

    // MARK: - Initilization
    override init(frame: NSRect) {
        super.init(frame: frame)

        initCommon()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - Private
    fileprivate func initCommon() {
        zoomLevel = 14
        styleURL = MGLStyle.streetsStyleURL(withVersion: 9)
        delegate = self
    }

    public func setupViewModel(_ viewModel: MapViewModelProtocol) {
        self.viewModel = viewModel
        binding()
    }

    fileprivate func binding() {

        // Update Location on map
        viewModel.output.currentPlaceDriver
            .drive(onNext: {[weak self] placeObj in
                guard let `self` = self else { return }
                Logger.info("set current place \(placeObj)")
                self.addOriginPoint(placeObj)

                if let pickupPoint = self.pickupPoint {
                    self.drawPickupRoute(pickupPoint.coordinate)
                }
            })
            .addDisposableTo(disposeBag)

        // Draw map
        viewModel.output.selectedDirectionRouteObserver
            .subscribe(onNext: {[weak self] (route) in
                guard let `self` = self else { return }
                self.drawTripRoute(route)
            })
            .addDisposableTo(disposeBag)

        viewModel.output.routeCurrentTrip
            .drive(onNext: {[weak self] (route) in
                guard let `self` = self else { return }
                self.drawTripRoute(route)
            })
            .addDisposableTo(disposeBag)
    }

    // MARK: - Public
    func configureLayout(_ parentView: NSView, exitBtn: NSButton) {
        translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(self, positioned: .below, relativeTo: exitBtn)
        edges(to: parentView)
    }

    fileprivate func addOriginPoint(_ placeObj: PlaceObj) {

        // Remove if need
        if let originPoint = originPoint {
            removeAnnotation(originPoint)
            self.originPoint = nil
        }

        originPoint = OriginAnnotation(placeObj: placeObj)
        addAnnotation(originPoint!)

        // CentralizeMap
        centralizeMap()
    }

    func addDestinationPlaceObj(_ placeObj: PlaceObj?) {

        // Remove if need
        if let currentPoint = destinationPoint {
            removeAnnotation(currentPoint)
            destinationPoint = nil
        }

        // Remove
        guard let placeObj = placeObj else { return }

        // Add
        destinationPoint = DestinationAnnotation(placeObj: placeObj)
        addAnnotation(destinationPoint!)

        // CentralizeMap
        centralizeMap()
    }

    func centralizeMap() {
        guard let annotations = annotations else {
            return
        }

        // Center
        if annotations.count == 1 {
            let centerPoint = annotations.first!
            setCenter(centerPoint.coordinate, animated: true)
            return
        }

        // Centeralize all visible annotations
        let edge = EdgeInsets(top: 200, left: 70, bottom: 70, right: 70)
        showAnnotations(annotations, edgePadding: edge, animated: true)
    }

    func updateCurrentTripLayout(_ tripObj: TripObj) {

        // Pickup
        addPickupPoint(tripObj.pickup)
        drawPickupRoute(tripObj.pickup?.coordinate)

        // Driver
        addDriverPoint(tripObj.driver, location: tripObj.location)
    }

    fileprivate func addPickupPoint(_ pickupObj: PickupPointObj?) {

        // Remove if need
        if let pickupPoint = pickupPoint {
            removeAnnotation(pickupPoint)
            self.pickupPoint = nil
        }

        guard let pickupObj = pickupObj else { return }

        pickupPoint = PickupAnnotation(pickup: pickupObj)
        addAnnotation(pickupPoint!)
    }

    fileprivate func addDriverPoint(_ driverObj: DriverObj?, location: UberCoordinateObj?) {

        // Remove if need
        if let driverPoint = driverPoint {
            removeAnnotation(driverPoint)
            self.driverPoint = nil
        }

        guard let location = location else { return }

        driverPoint = MGLPointAnnotation()
        driverPoint!.coordinate = CLLocationCoordinate2D(latitude: location.latitude.toDouble,
                                                              longitude: location.longitude.toDouble)
        driverPoint!.title = "Driver"
        addAnnotation(driverPoint!)
    }
}

// MARK: - Route
extension UberMapView {

    fileprivate func drawTripRoute(_ route: Route?) {

        // Reset all Draw
        resetCurrentRoute()

        guard let route = route else { return }
        guard route.coordinateCount > 0 else { return }
        guard var routeCoordinates = route.coordinates else { return }

        // Convert the route’s coordinates into a polyline.
        let routeLine = MGLPolyline(coordinates: &routeCoordinates, count: route.coordinateCount)

        // Add the polyline to the map and fit the viewport to the polyline.
        addAnnotation(routeLine)
        visibleRoute = routeLine

        // Centerizal
        centralizeMap()
    }

    fileprivate func drawPickupRoute(_ pickup: CLLocationCoordinate2D?) {
        guard let pickup = pickup else { return }
        guard let originPoint = self.originPoint else { return }
        guard let style = self.style else { return }

        // Remove if need
        resetPickupDashedLine()

        var coordinates = [originPoint.coordinate,
                          pickup]

        // Source
        let polyline = MGLPolylineFeature(coordinates: &coordinates, count: UInt(coordinates.count))
        let source = MGLShapeSource(identifier: "pickup-dash-line", features: [polyline], options: nil)
        style.addSource(source)

        // Dashed line
        let dashedLine = PickupDashedLine.defaultDashedLine(with: source)
        style.addLayer(dashedLine)

        pickupPointLine = dashedLine
        pickupPointSource = source
    }
}

// MARK: - Reset
extension UberMapView {

    public func resetAllData() {

        // Reset Route
        resetCurrentRoute()

        // Remove Annotation, except Origin
        removeAnnotations(annotationExclusiveOriginPoint())

        // Remove dash
        self.resetPickupDashedLine()

        // Reset
        destinationPoint = nil
        pickupPoint = nil
        driverPoint = nil
    }

    public func resetCurrentRoute() {
        if let visibleRoute = visibleRoute {
            removeAnnotation(visibleRoute)
            self.visibleRoute = nil
        }
    }

    fileprivate func resetPickupDashedLine() {
        guard let style = self.style else { return }
        if let pickupPointSource = pickupPointSource {
            style.removeSource(pickupPointSource)
            style.removeLayer(pickupPointLine!)
            self.pickupPointSource = nil
            self.pickupPointLine = nil
        }

    }

    fileprivate func annotationExclusiveOriginPoint() -> [MGLAnnotation] {
        guard let anno = annotations else { return [] }
        return anno.filter { ($0 as? OriginAnnotation) == nil }
    }
}

// MARK: - MGLMapViewDelegate
extension UberMapView: MGLMapViewDelegate {

    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }

    func mapView(_ mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
        return 0.8
    }

    func mapView(_ mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
        return 4.0
    }

    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        if let obj = annotation as? UberAnnotationType {
            return obj.imageAnnotation
        }
        return nil
    }

    func mapView(_ mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> NSColor {
        return NSColor(hexString: "#52565f")
    }

    func mapView(_ mapView: MGLMapView, calloutViewControllerFor annotation: MGLAnnotation) -> NSViewController? {

        if let obj = annotation as? UberAnnotationType {
            if let annotation = annotation as? OriginAnnotation {
                let timeObj = uberMapDelegate?.uberMapViewTimeEstimateForOriginAnnotation()
                annotation.setupCallout(timeObj: timeObj)
            }
            return obj.calloutViewController
        }

        return nil
    }
}
