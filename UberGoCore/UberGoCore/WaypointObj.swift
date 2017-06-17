//
//  WaypointObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/13/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import CoreLocation
import Foundation
import ObjectMapper

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

open class WaypointObj: BaseObj {

    // MARK: - Variable
    public var riderId: String?
    public var latitude: Double?
    public var longitude: Double?
    fileprivate var typeStr: String?

    public lazy var type: WaypointType = {
        return WaypointType.initFromTypeString(self.typeStr!)
    }()

    public var location: CLLocationCoordinate2D? {
        return CLLocationCoordinate2D(latitude: self.latitude!,
                                      longitude: self.longitude!)
    }

    override public func mapping(map: Map) {
        super.mapping(map: map)

        self.riderId <- map[Constants.Object.Waypoint.RiderId]
        self.typeStr <- map[Constants.Object.Waypoint.Type]
        self.latitude <- map[Constants.Object.Waypoint.Latitude]
        self.longitude <- map[Constants.Object.Waypoint.Longitude]
    }
}
