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
    }

    // MARK: - Public
    func configureLayout(_ parentView: NSView, exitBtn: NSButton) {
        self.translatesAutoresizingMaskIntoConstraints = true
        self.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
        parentView.addSubview(self, positioned: .below, relativeTo: exitBtn)
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
        guard let coordinate = placeObj.coordinate2D else {
            return
        }
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
}
