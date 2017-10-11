//
//  TripObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/2/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Unbox
import Wrap

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

public final class TripObj: Unboxable {

    // MARK: - Variable
    public var productId: String
    public var requestId: String
    fileprivate var _status: String
    public var surgeMultiplier: Float?
    public var shared: Bool
    public var driver: DriverObj?
    public var vehicle: VehicleObj?
    public var location: UberCoordinateObj?
    public var pickup: PickupPointObj?
    public var destination: PickupPointObj?
    public var waypoints: [WaypointObj]?
    public var riders: [RiderObj]?

    public lazy var status: TripObjStatus = {
        return TripObjStatus.createTripStatus(rawValue: self._status)
    }()

    public var isValidTrip: Bool {
        switch status {
            case .unknown,
                 .completed,
                 .driverCanceled,
                 .riderCanceled,
                 .noDriversAvailable:
                return false
            case .accepted,
                 .arriving,
                 .inProgress,
                 .processing:
                return true
        }
    }

    // MARK: - Init
    public init(productId: String, requestId: String, status: String, surgeMultiplier: Float, shared: Bool) {
        self.productId = productId
        self.requestId = requestId
        self._status = status
        self.surgeMultiplier = surgeMultiplier
        self.shared = shared
    }

    public class func invalidDummyTrip() -> TripObj {
        return TripObj(productId: "",
                       requestId: "",
                       status: TripObjStatus.unknown.rawValue,
                       surgeMultiplier: 0,
                       shared: false)
    }

    public required init(unboxer: Unboxer) throws {
        productId = try unboxer.unbox(key: Constants.Object.Trip.ProductId)
        requestId = try unboxer.unbox(key: Constants.Object.Trip.RequestId)
        _status = try unboxer.unbox(key: Constants.Object.Trip.Status)
        surgeMultiplier = unboxer.unbox(key: Constants.Object.Trip.SurgeMultiplier)
        shared = try unboxer.unbox(key: Constants.Object.Trip.Shared)
        driver = unboxer.unbox(key: Constants.Object.Trip.Driver)
        vehicle = unboxer.unbox(key: Constants.Object.Trip.Vehicle)
        location = unboxer.unbox(key: Constants.Object.Trip.Location)
        pickup = unboxer.unbox(key: Constants.Object.Trip.Pickup)
        destination = unboxer.unbox(key: Constants.Object.Trip.Destination)
        waypoints = unboxer.unbox(key: Constants.Object.Trip.Waypoints)
        riders = unboxer.unbox(key: Constants.Object.Trip.Riders)
    }
}

extension TripObj: CustomDebugStringConvertible, CustomStringConvertible {

    public var debugDescription: String {
        return _desciption()
    }

    public var description: String {
        return _desciption()
    }

    fileprivate func _desciption() -> String {
        guard let result = try? wrap(self) else {
            return ""
        }
        return "\(result)"
    }
}
