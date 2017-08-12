//
//  LocationHelper.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/13/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import CoreLocation
import Foundation
import UberGoCore

class LocationHelper {

    // Coffee house
    static let originLocation = CLLocationCoordinate2D(latitude: 10.78516492,
                                                       longitude: 106.70281425)
    static let fromPlace = PlaceObj(coordinate: LocationHelper.originLocation)

    // RMIT
    static let destinationLocation = CLLocationCoordinate2D(latitude: 10.72928685,
                                                            longitude: 106.69390261)
    static let toPlace = PlaceObj(coordinate: LocationHelper.destinationLocation)

    // Test
    static let testablePlaceData = UberRequestTripData(from: LocationHelper.fromPlace,
                                                       to: LocationHelper.toPlace)
}
