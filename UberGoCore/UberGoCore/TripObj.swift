//
//  TripObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/2/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Unbox

public enum TripObjStatus: String {
    case processing
    case noDriversAvailable = "no_drivers_available"
    case accepted
    case arriving
    case inProgress = "in_progress"
    case driverCanceled = "driver_canceled"
    case riderCanceled = "rider_canceled"
    case completed
    case unknown

    public static func createTripStatus(rawValue: String) -> TripObjStatus {
        guard let status = TripObjStatus(rawValue: rawValue) else {
            return .unknown
        }
        return status
    }

    public var prettyValue: String {
        switch self {
        case .processing:
            return "Processing"
        case .noDriversAvailable:
            return "No Driver Available"
        case .accepted:
            return "Accepted"
        case .arriving:
            return "Arriving"
        case .inProgress:
            return "In Progress"
        case .driverCanceled:
            return "Driver Canceled"
        case .riderCanceled:
            return "Rider Canceled"
        case .completed:
            return "Completed"
        case .unknown:
            return "Unknown"
        }
    }
}

open class TripObj: BaseObj {

    // MARK: - Variable
    public var productId: String?
    public var requestId: String?
    fileprivate var _status: String?
    public var surgeMultiplier: Double?
    public var shared: Bool?
    public var driver: DriverObj?
    public var vehicle: VehicleObj?
    public var location: UberCoordinateObj?
    public var pickup: UberCoordinateObj?
    public var destination: UberCoordinateObj?
    public var waypoints: [WaypointObj]?
    public var riders: [RiderObj]?
    public lazy var status: TripObjStatus = {
        guard let _status = self._status else {
            return .unknown
        }
        return TripObjStatus.createTripStatus(rawValue: _status)
    }()

    public var isValidTrip: Bool {
        switch self.status {
            case .unknown:
                fallthrough
            case .completed:
                fallthrough
            case .driverCanceled:
                fallthrough
            case .riderCanceled:
                fallthrough
            case .noDriversAvailable:
                return false

            case .accepted:
                fallthrough
            case .arriving:
                fallthrough
            case .inProgress:
                fallthrough
            case .processing:
                return true
        }
    }

    override public func mapping(map: Map) {
        super.mapping(map: map)

        self.productId <- map[Constants.Object.Trip.ProductId]
        self.requestId <- map[Constants.Object.Trip.RequestId]
        self._status <- map[Constants.Object.Trip.Status]
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

    class func noCurrentTrip() -> TripObj {
        let obj = TripObj()
        obj._status = TripObjStatus.unknown.rawValue
        return obj
    }
}
