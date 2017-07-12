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
    public var latitude: Double?
    public var longitude: Double?
    public var bearing: Double?
    public var eta: Int?

    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude!, longitude: self.longitude!)
    }
    
    override public func mapping(map: Map) {
        super.mapping(map: map)

        self.latitude = try unboxer.unbox(key: "latitude")
        self.longitude = try unboxer.unbox(key: "longitude")
        self.bearing = try unboxer.unbox(key: "bearing")
        self.eta = try unboxer.unbox(key: "eta")
    }
}
