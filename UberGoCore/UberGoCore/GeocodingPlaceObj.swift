//
//  GeocodingObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 8/3/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import CoreLocation
import Unbox

open class GeocodingPlaceObj: NSObject, Unboxable {

    // MARK: - Variable
    public var address: String
    public var placeID: String
    public var location: [String: Float]

    // Coordinate
    public lazy var coordinate2D: CLLocationCoordinate2D = {
        let lat = self.location["lat"]!.toDouble
        let lng = self.location["lng"]!.toDouble
        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }()

    // MARK: - Init
    public init(address: String, placeID: String, location: [String: Float]) {
        self.address = address
        self.placeID = placeID
        self.location = location
    }
    // Map
    public required init(unboxer: Unboxer) throws {
        address = try unboxer.unbox(key: "formatted_address")
        location = try unboxer.unbox(keyPath: "geometry.location")
        placeID = try unboxer.unbox(key: "place_id")
    }
}
