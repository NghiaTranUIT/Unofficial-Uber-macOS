//
//  PickupPointObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 8/30/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import CoreLocation
import Unbox

public class PickupPointObj: Unboxable {

    // MARK: - Variable
    public let alias: String?
    public let latitude: Float
    public let longitude: Float
    public let name: String?
    public let address: String?
    public let eta: Int?

    public var prettyETA: String? {
        guard let eta = self.eta else { return nil }
        return "\(eta)"
    }

    // Coordinate
    public lazy var coordinate: CLLocationCoordinate2D = {
        return CLLocationCoordinate2D(latitude: CLLocationDegrees(self.latitude),
                                      longitude: CLLocationDegrees(self.longitude))
    }()

    // MARK: - Init
    public required init(unboxer: Unboxer) throws {
        alias = unboxer.unbox(key: Constants.Object.PickupPoint.Alias)
        latitude = try unboxer.unbox(key: Constants.Object.PickupPoint.Latitude)
        longitude = try unboxer.unbox(key: Constants.Object.PickupPoint.Longitude)
        name = unboxer.unbox(key: Constants.Object.PickupPoint.Name)
        address = unboxer.unbox(key: Constants.Object.PickupPoint.Address)
        eta = unboxer.unbox(key: Constants.Object.PickupPoint.Eta)
    }
}
