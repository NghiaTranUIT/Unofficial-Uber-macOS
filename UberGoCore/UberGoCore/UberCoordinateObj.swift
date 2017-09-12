//
//  UberCoordinateObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/14/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import CoreLocation
import Unbox

public class UberCoordinateObj: Unboxable {

    // MARK: - Variable
    public var latitude: Float
    public var longitude: Float
    public var bearing: Float?
    public var eta: Int?

    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude.toDouble,
                                      longitude: longitude.toDouble)
    }

    // MARK: - Init
    public required init(unboxer: Unboxer) throws {
        latitude = try unboxer.unbox(key: "latitude")
        longitude = try unboxer.unbox(key: "longitude")
        bearing = unboxer.unbox(key: "bearing")
        eta = unboxer.unbox(key: "eta")
    }
}
