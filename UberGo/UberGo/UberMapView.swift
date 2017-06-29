//
//  UberMapView.swift
//  UberGo
//
//  Created by Nghia Tran on 6/16/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Mapbox
import MapboxDirections
import UberGoCore

class UberMapView: MGLMapView {

    // MARK: - Variable

    // Origin
    fileprivate var originPoint: MGLPointAnnotation?

    // Destination
    fileprivate var destinationPoint: MGLPointAnnotation?

    // Pickup place
    fileprivate var pickupPoint: MGLPointAnnotation?

    // Driver Place
    fileprivate var driverPoint: MGLPointAnnotation?

    // Visible Route
    fileprivate var visibleRoute: MGLPolyline?

    fileprivate var circleSource: MGLShapeSource?

    fileprivate lazy var testCircleImage: MGLAnnotationImage = {
        let imageLayer = MGLAnnotationImage(image: NSImage(imageLiteralResourceName: "current_mark"), reuseIdentifier: "current_mark")
        return imageLayer
    }()

    // MARK: - Initilization
    override init(frame: NSRect) {
        super.init(frame: frame)

        self.initCommon()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - Private
    fileprivate func initCommon() {
        self.zoomLevel = 14
        self.styleURL = MGLStyle.darkStyleURL(withVersion: 9)
        self.delegate = self
    }

    // MARK: - Public
    func configureLayout(_ parentView: NSView, exitBtn: NSButton) {
        self.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(self, positioned: .below, relativeTo: exitBtn)
        self.edges(to: parentView)
    }

    func addOriginPoint(_ point: CLLocationCoordinate2D) {

        // Remove if need
        if let originPoint = self.originPoint {
            self.removeAnnotation(originPoint)
            self.originPoint = nil
        }

        //let newPoint = CirclePolygon.circleForCoordinate(point, withMeterRadius: 100)

        let newPoint = MGLPointAnnotation()
        newPoint.coordinate = point
        newPoint.title = "Here"

//        if self.circleSource == nil {
//
//            let source = MGLShapeSource(identifier: "circle", shape: newPoint, options: nil)
//            self.circleSource = source
//            style?.addSource(source)
//
//            let layer = MGLCircleStyleLayer(identifier: "circle", source: source)
//            let radiusPoints = 40.0 / self.metersPerPoint(atLatitude: point.latitude)
//            layer.circleRadius = MGLStyleValue(rawValue: NSNumber(value: radiusPoints))
//            layer.circleColor = MGLStyleValue(rawValue: NSColor.white)
//            layer.circleOpacity = MGLStyleValue(rawValue: 1)
//            style?.addLayer(layer)
//        }

        // Add
        self.addAnnotation(newPoint)
        self.originPoint = newPoint

        // CentralizeMap
        self.centralizeMap()
    }

    func addDestinationPlaceObj(_ placeObj: PlaceObj?) {

        // Remove if need
        if let currentPoint = self.destinationPoint {
            self.removeAnnotation(currentPoint)
            self.destinationPoint = nil
        }

        // Remove
        guard let placeObj = placeObj else { return }

        // Add
        guard let coordinate = placeObj.coordinate2D else { return }

        self.destinationPoint = MGLPointAnnotation()
        self.destinationPoint!.coordinate = coordinate
        self.destinationPoint!.title = placeObj.name
        self.addAnnotation(self.destinationPoint!)

        // CentralizeMap
        self.centralizeMap()
    }

    func centralizeMap() {
        guard let annotations = self.annotations else {
            return
        }

        // Center
        if annotations.count == 1 {
            let centerPoint = annotations.first!
            self.setCenter(centerPoint.coordinate, animated: true)
            return
        }

        // Centeralize all visible annotations
        let edge = EdgeInsets(top: 200, left: 70, bottom: 70, right: 70)
        self.showAnnotations(annotations, edgePadding: edge, animated: true)
    }

    func updateCurrentTripLayout(_ tripObj: TripObj) {

        // Pickup
        self.addPickupPoint(tripObj.pickup)

        // Driver
        self.addDriverPoint(tripObj.driver, location: tripObj.location)
    }

    fileprivate func addPickupPoint(_ pickupObj: UberCoordinateObj?) {

        // Remove if need
        if let pickupPoint = self.pickupPoint {
            self.removeAnnotation(pickupPoint)
            self.pickupPoint = nil
        }

        guard let pickupObj = pickupObj else { return }

        self.pickupPoint = MGLPointAnnotation()
        self.pickupPoint!.coordinate = CLLocationCoordinate2D(latitude: pickupObj.latitude!,
                                                              longitude: pickupObj.longitude!)
        self.pickupPoint!.title = "Pickup"
        self.addAnnotation(self.pickupPoint!)
    }

    fileprivate func addDriverPoint(_ driverObj: DriverObj?, location: UberCoordinateObj?) {

        // Remove if need
        if let driverPoint = self.driverPoint {
            self.removeAnnotation(driverPoint)
            self.driverPoint = nil
        }

        guard let location = location else { return }

        self.driverPoint = MGLPointAnnotation()
        self.driverPoint!.coordinate = CLLocationCoordinate2D(latitude: location.latitude!,
                                                              longitude: location.longitude!)
        self.driverPoint!.title = "Driver"
        self.addAnnotation(self.driverPoint!)
    }

}

// MARK: - Route
extension UberMapView {

    func drawVisbileRoute(_ route: Route?) {

        // Reset all Draw
        self.resetCurrentRoute()

        guard let route = route else { return }

        if route.coordinateCount > 0 {

            // Convert the route’s coordinates into a polyline.
            var routeCoordinates = route.coordinates!
            let routeLine = MGLPolyline(coordinates: &routeCoordinates, count: route.coordinateCount)

            // Add the polyline to the map and fit the viewport to the polyline.
            self.addAnnotation(routeLine)
            self.visibleRoute = routeLine

            // Centerizal
            self.centralizeMap()
        } else {
            assert(false, "route.coordinateCount == 0")
        }
    }
}

// MARK: - Reset
extension UberMapView {

    public func resetAllData() {

        // Reset Route
        self.resetCurrentRoute()

        // Remove point
        if let anno = self.annotations {
            self.removeAnnotations(anno)
        }
        self.originPoint = nil
        self.destinationPoint = nil
        self.pickupPoint = nil
        self.driverPoint = nil
    }

    public func resetCurrentRoute() {
        if let visibleRoute = self.visibleRoute {
            self.removeAnnotation(visibleRoute)
            self.visibleRoute = nil
        }
    }
}

// MARK: - MGLMapViewDelegate
extension UberMapView: MGLMapViewDelegate {

    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }

    func mapView(_ mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {

        // Current Point
        if annotation is CirclePolygon {
            return 1.0
        }

        // Route
        return 0.8
    }

    func mapView(_ mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {

        // Route
        return 3.0
    }

    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        return self.testCircleImage
    }

    func mapView(_ mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> NSColor {

        if annotation is CirclePolygon {
            return NSColor.black
        }

        return NSColor.white
    }

    func mapViewRegionIsChanging(_ mapView: MGLMapView) {

        guard let originPoint = self.originPoint else {
            return
        }

//        if let layer = mapView.style?.layer(withIdentifier: "circle") as? MGLCircleStyleLayer {
//            let radiusPoints = 40.0 / self.metersPerPoint(atLatitude: originPoint.coordinate.latitude)
//            layer.circleRadius = MGLStyleValue(rawValue: NSNumber(value: radiusPoints))
//        }
    }
}
