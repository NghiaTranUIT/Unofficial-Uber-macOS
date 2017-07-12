//
//  Coordinate2DTransform.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/13/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa
import CoreLocation
import Unbox

open class Coordinate2DTransform: TransformType {
    public typealias Object = CLLocationCoordinate2D
    public typealias JSON = [String: Double]

    public init() {}

    open func transformFromJSON(_ value: Any?) -> Object? {
        guard let value = value as? JSON else {
            return nil
        }
        guard let lat = value["lat"] else {
            return nil
        }
        guard let lng = value["lng"] else {
            return nil
        }
        return CLLocationCoordinate2D(latitude: lat,
                                      longitude: lng)
    }

    open func transformToJSON(_ value: Object?) -> JSON? {
        guard let value = value else {
            return nil
        }
        return ["lat": value.latitude,
                "lng": value.longitude]
    }
}
