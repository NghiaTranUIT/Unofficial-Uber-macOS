//
//  WaypointObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/13/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import CoreLocation
import Foundation
import Unbox

public enum WaypointType: String {
    case pickup
    case dropoff
    case unknown

    static func initFromTypeString(_ rawValue: String) -> WaypointType {
        if rawValue == WaypointType.pickup.rawValue {
            return .pickup
        }
        if rawValue == WaypointType.dropoff.rawValue {
            return .dropoff
        }
        return .unknown
    }
}

open class WaypointObj: Unboxable {

    // MARK: - Variable
    public var riderId: String?
    public var latitude: Float
    public var longitude: Float
    fileprivate var typeStr: String

    // Type enum
    public lazy var type: WaypointType = {
        return WaypointType.initFromTypeString(self.typeStr)
    }()

    // Coordinate
    public var location: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude.toDouble,
                                      longitude: self.longitude.toDouble)
    }

    // MARK: - Init
    public required init(unboxer: Unboxer) throws {
        self.riderId = unboxer.unbox(key: Constants.Object.Waypoint.RiderId)
        self.typeStr = try unboxer.unbox(key: Constants.Object.Waypoint.Type)
        self.latitude = try unboxer.unbox(key: Constants.Object.Waypoint.Latitude)
        self.longitude = try unboxer.unbox(key: Constants.Object.Waypoint.Longitude)
    }
}
