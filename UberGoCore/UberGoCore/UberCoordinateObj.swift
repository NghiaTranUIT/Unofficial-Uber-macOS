//
//  UberCoordinateObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/14/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import CoreLocation
import Unbox

open class UberCoordinateObj: BaseObj {

    // MARK: - Variable
    public var latitude: Float
    public var longitude: Float
    public var bearing: Float
    public var eta: Int

    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude.toDouble,
                                      longitude: self.longitude.toDouble)
    }

    // MARK: - Init
    public required init(unboxer: Unboxer) throws {
        self.latitude = try unboxer.unbox(key: "latitude")
        self.longitude = try unboxer.unbox(key: "longitude")
        self.bearing = try unboxer.unbox(key: "bearing")
        self.eta = try unboxer.unbox(key: "eta")
        try super.init(unboxer: unboxer)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
