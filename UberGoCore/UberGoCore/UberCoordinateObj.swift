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

        self.latitude <- map["latitude"]
        self.longitude <- map["longitude"]
        self.bearing <- map["bearing"]
        self.eta <- map["eta"]
    }
}
