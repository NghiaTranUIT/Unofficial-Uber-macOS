//
//  CircleShape.swift
//  UberGo
//
//  Created by Nghia Tran on 6/29/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation
import Mapbox

// Ref: https://github.com/mapbox/mapbox-gl-native/issues/2167
class CirclePolygon: MGLPolygon {

    class func circleForCoordinate(_ coordinate: CLLocationCoordinate2D, withMeterRadius: Double) -> CirclePolygon {

        let degreesBetweenPoints = 8.0
        let numberOfPoints = floor(360.0 / degreesBetweenPoints)
        let distRadians: Double = withMeterRadius / 6371000.0
        let centerLatRadians: Double = coordinate.latitude * Double.pi / 180.0
        let centerLonRadians: Double = coordinate.longitude * Double.pi / 180.0
        var coordinates = [CLLocationCoordinate2D]()

        for i in 0..<Int(numberOfPoints) {
            let degrees: Double = Double(i) * Double(degreesBetweenPoints)
            let degreeRadians: Double = degrees * Double.pi / 180
            let pointLatRadians: Double = asin(sin(centerLatRadians) * cos(distRadians) + cos(centerLatRadians) * sin(distRadians) * cos(degreeRadians))
            let pointLonRadians: Double = centerLonRadians + atan2(sin(degreeRadians) * sin(distRadians) * cos(centerLatRadians), cos(distRadians) - sin(centerLatRadians) * sin(pointLatRadians))
            let pointLat: Double = pointLatRadians * 180 / Double.pi
            let pointLon: Double = pointLonRadians * 180 / Double.pi
            let point: CLLocationCoordinate2D = CLLocationCoordinate2DMake(pointLat, pointLon)
            coordinates.append(point)
        }

        return CirclePolygon(coordinates: &coordinates, count: UInt(coordinates.count))
    }
}
