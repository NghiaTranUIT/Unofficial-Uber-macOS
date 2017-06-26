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
    fileprivate var destinationPlaceObj: PlaceObj?
    fileprivate var destinationPoint: MGLPointAnnotation?
    fileprivate var directionRoute: MGLPolyline?

    // Pickup place
    fileprivate var pickupPlace: UberCoordinateObj?
    fileprivate var pickupPoint: MGLPointAnnotation?
    fileprivate var pickupRoute: MGLPolyline?

    // Driver Place
    fileprivate var driverPlace: DriverObj?
    fileprivate var driverPoint: MGLPointAnnotation?
    fileprivate var driverRoute: MGLPolyline?

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

        let top = NSLayoutConstraint(item: self,
                                                attribute: .top,
                                                relatedBy: .equal,
                                                toItem: parentView,
                                                attribute: .top,
                                                multiplier: 1,
                                                constant: 0)
        let left = NSLayoutConstraint(item: self,
                                                 attribute: .left,
                                                 relatedBy: .equal,
                                                 toItem: parentView,
                                                 attribute: .left,
                                                 multiplier: 1,
                                                 constant: 0)
        let right = NSLayoutConstraint(item: self,
                                                  attribute: .right,
                                                  relatedBy: .equal,
                                                  toItem: parentView,
                                                  attribute: .right,
                                                  multiplier: 1,
                                                  constant: 0)
        let bottom = NSLayoutConstraint(item: self,
                                                   attribute: .bottom,
                                                   relatedBy: .equal,
                                                   toItem: parentView, attribute: .bottom,
                                                   multiplier: 1,
                                                   constant: 0)
        parentView.addConstraints([top, left, right, bottom])
    }

    func addOriginPoint(_ point: CLLocationCoordinate2D) {

        // Remove if need
        if let originPoint = self.originPoint {
            self.removeAnnotation(originPoint)
            self.originPoint = nil
        }

        let newPoint = MGLPointAnnotation()
        newPoint.coordinate = point
        newPoint.title = "Here"

        // Add
        self.addAnnotation(newPoint)
        self.originPoint = newPoint

        // CentralizeMap
        self.centralizeMap()
    }

    func addDestinationPlaceObj(_ placeObj: PlaceObj?) {
        self.destinationPlaceObj = placeObj

        // Remove if need
        if let currentPoint = self.destinationPoint {
            self.removeAnnotation(currentPoint)
            self.destinationPoint = nil
        }

        // Remove
        guard let placeObj = placeObj else {
            self.centralizeMap()
            return
        }

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

    func drawDirectionRoute(_ route: Route?) {

        guard let route = route else {
            // Remove if need
            if let directionRoute = self.directionRoute {
                self.removeAnnotation(directionRoute)
                self.directionRoute = nil
            }
            return
        }

        if route.coordinateCount > 0 {

            // Remove if need
            if let directionRoute = self.directionRoute {
                self.removeAnnotation(directionRoute)
                self.directionRoute = nil
            }

            // Convert the route’s coordinates into a polyline.
            var routeCoordinates = route.coordinates!
            let routeLine = MGLPolyline(coordinates: &routeCoordinates, count: route.coordinateCount)

            // Add the polyline to the map and fit the viewport to the polyline.
            self.addAnnotation(routeLine)
            self.directionRoute = routeLine

            // Centerizal
            self.centralizeMap()
        } else {
            assert(false, "route.coordinateCount == 0")
        }
    }

    func updateCurrentTripLayout(_ tripObj: TripObj) {

        // Pickup
        self.addPickupPoint(tripObj.pickup)

        // Driver
        self.addDriverPoint(tripObj.driver, location: tripObj.location)

        // Draw route
        self.drawCurrentTripRoute()
    }

    fileprivate func addPickupPoint(_ pickupObj: UberCoordinateObj?) {

        self.pickupPlace = pickupObj

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

        self.driverPlace = driverObj

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

    fileprivate func drawCurrentTripRoute() {

    }
}

// MARK: - MGLMapViewDelegate
extension UberMapView: MGLMapViewDelegate {

    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }

    func mapView(_ mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
        // Set the alpha for all shape annotations to 1 (full opacity)
        return 0.8
    }

    func mapView(_ mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
        // Set the line width for polyline annotations
        return 3.0
    }

    func mapView(_ mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> NSColor {
        // Give our polyline a unique color by checking for its `title` property
        return NSColor.white
    }
}
