//
//  PlaceObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/2/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import CoreLocation
import Unbox

// PlaceType
public enum PlaceType: String {
    case home
    case work
    case place

    static func fromUberPersonalPlaceType(_ type: UberPersonalPlaceType) -> PlaceType {
        switch type {
        case .home:
            return PlaceType.home
        case .work:
            return PlaceType.work
        }
    }
}

// Google Place
open class PlaceObj: NSObject, Unboxable, NSCoding {

    // MARK: - Variable
    public var placeType = PlaceType.place
    public var name: String
    public var address: String
    public var placeID: String
    public var location: [String: Float]
    public var isHistory = false

    public lazy var coordinate2D: CLLocationCoordinate2D = {
        let lat = self.location["lat"]!.toDouble
        let lng = self.location["lng"]!.toDouble
        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }()

    // Invalid
    static var invalid: PlaceObj {
        return PlaceObj(placeType: PlaceType.place, name: "", address: "", placeID: "", location: [:])
    }

    // MARK: - Init
    public init(placeType: PlaceType, name: String, address: String, placeID: String, location: [String: Float]) {
        self.placeType = placeType
        self.name = name
        self.address = address
        self.placeID = placeID
        self.location = location
    }

    public convenience init(coordinate: CLLocationCoordinate2D) {
        self.init(placeType: .place,
                  name: "Current Location",
                  address: "Current Location",
                  placeID: "Current Location",
                  location: ["lat": coordinate.latitude.toFloat,
                             "lng": coordinate.longitude.toFloat])
    }

    public convenience init(personalPlaceObj: UberPersonalPlaceObj) {
        let name = personalPlaceObj.placeType.rawValue
        let address = personalPlaceObj.address
        let placeType = PlaceType.fromUberPersonalPlaceType(personalPlaceObj.placeType)
        let placeID = placeType.rawValue
        self.init(placeType: placeType, name: name, address: address, placeID: placeID, location: [:])
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(address, forKey: "vicinity")
        aCoder.encode(location, forKey: "geometry.location")
        aCoder.encode(placeType.rawValue, forKey: "placeType")
        aCoder.encode(placeID, forKey: "placeID")
    }

    public required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "name") as! String
        address = aDecoder.decodeObject(forKey: "vicinity") as! String
        location = aDecoder.decodeObject(forKey: "geometry.location") as! [String: Float]
        isHistory = true
        placeType = PlaceType(rawValue: aDecoder.decodeObject(forKey: "placeType") as! String)!
        placeID = aDecoder.decodeObject(forKey: "placeID") as! String
    }

    // Map
    public required init(unboxer: Unboxer) throws {
        name = try unboxer.unbox(key: "name")
        address = try unboxer.unbox(key: "vicinity")
        location = try unboxer.unbox(keyPath: "geometry.location")
        placeID = try unboxer.unbox(key: "place_id")
    }

    // MARK: - Public
    public var iconName: String {
        if isHistory { return "history" }
        switch placeType {
        case .home:
            return "home"
        case .work:
            return "work"
        case .place:
            return "place"
        }
    }

    public static func == (lhs: PlaceObj, rhs: PlaceObj) -> Bool {
        return lhs.placeID == rhs.placeID
    }
}
