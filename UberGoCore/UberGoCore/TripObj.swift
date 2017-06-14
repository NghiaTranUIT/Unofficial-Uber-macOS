//
//  TripObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/2/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import ObjectMapper

open class TripObj: BaseObj {

    // MARK: - Variable
    public var productId: String?
    public var requestId: String?
    public var status: String?
    public var surgeMultiplier: Double?
    public var shared: Bool?
    public var driver: DriverObj?
    public var vehicle: VehicleObj?
    public var location: UberCoordinateObj?
    public var pickup: UberCoordinateObj?
    public var destination: UberCoordinateObj?
    public var waypoints: [WaypointObj]?
    public var riders: [RiderObj]?

    override public func mapping(map: Map) {
        super.mapping(map: map)

        self.productId <- map[Constants.Object.Trip.ProductId]
        self.requestId <- map[Constants.Object.Trip.RequestId]
        self.status <- map[Constants.Object.Trip.Status]
        self.surgeMultiplier <- map[Constants.Object.Trip.SurgeMultiplier]
        self.shared <- map[Constants.Object.Trip.Shared]
        self.driver <- map[Constants.Object.Trip.Driver]
        self.vehicle <- map[Constants.Object.Trip.Vehicle]
        self.location <- map[Constants.Object.Trip.Location]
        self.pickup <- map[Constants.Object.Trip.Pickup]
        self.destination <- map[Constants.Object.Trip.Destination]
        self.waypoints <- map[Constants.Object.Trip.Waypoints]
        self.riders <- map[Constants.Object.Trip.Riders]
    }
}
