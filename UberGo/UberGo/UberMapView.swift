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
    fileprivate var viewModel: MapViewModel!
    fileprivate let disposeBag = DisposeBag()

    // Origin
    fileprivate var originPoint: OriginAnnotation?

    // Destination
    fileprivate var destinationPoint: DestinationAnnotation?

    // Pickup place
    fileprivate var pickupPoint: PickupAnnotation?

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

    public func setupViewModel(_ viewModel: MapViewModel) {
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
            })
            .addDisposableTo(disposeBag)

        // Draw map
        viewModel.output.selectedDirectionRouteObserver
            .subscribe(onNext: {[weak self] (route) in
                guard let `self` = self else { return }
                self.drawVisbileRoute(route)
            })
            .addDisposableTo(disposeBag)

        viewModel.output.routeCurrentTrip
            .drive(onNext: {[weak self] (route) in
                guard let `self` = self else { return }
                self.drawVisbileRoute(route)
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

        // Driver
        addDriverPoint(tripObj.driver, location: tripObj.location)
    }

    fileprivate func addPickupPoint(_ pickupObj: UberCoordinateObj?) {

        // Remove if need
        if let pickupPoint = pickupPoint {
            removeAnnotation(pickupPoint)
            self.pickupPoint = nil
        }

        guard let pickupObj = pickupObj else { return }

        pickupPoint = PickupAnnotation()
        pickupPoint!.coordinate = CLLocationCoordinate2D(latitude: pickupObj.latitude.toDouble,
                                                              longitude: pickupObj.longitude.toDouble)
        pickupPoint!.title = "Pickup"
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

    func drawVisbileRoute(_ route: Route?) {

        // Reset all Draw
        resetCurrentRoute()

        guard let route = route else { return }

        if route.coordinateCount > 0 {

            // Convert the route’s coordinates into a polyline.
            var routeCoordinates = route.coordinates!
            let routeLine = MGLPolyline(coordinates: &routeCoordinates, count: route.coordinateCount)

            // Add the polyline to the map and fit the viewport to the polyline.
            addAnnotation(routeLine)
            visibleRoute = routeLine

            // Centerizal
            centralizeMap()
        } else {
            assert(false, "route.coordinateCount == 0")
        }
    }
}

// MARK: - Reset
extension UberMapView {

    public func resetAllData() {

        // Reset Route
        resetCurrentRoute()

        // Remove Annotation
        // Except Origin
        removeAnnotations(annotationExclusiveOriginPoint())
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
