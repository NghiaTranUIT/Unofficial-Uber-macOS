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
open class PlaceObj: Unboxable, Equatable {

    // MARK: - Variable
    public var placeType = PlaceType.place
    public var name: String
    public var address: String
    public var placeID: String
    public var location: [String: Float]
    public var isHistory = false

    public lazy var coordinate2D: CLLocationCoordinate2D = {
        let lat = Double(self.location["lat"]!)
        let lng = Double(self.location["lng"]!)
        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }()

    // MARK: - Init
    public init(personalPlaceObj: UberPersonalPlaceObj) {
        self.name = personalPlaceObj.placeType.rawValue
        self.address = personalPlaceObj.address
        self.placeType = PlaceType.fromUberPersonalPlaceType(personalPlaceObj.placeType)
        self.placeID = self.placeType.rawValue
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.address, forKey: "vicinity")
        aCoder.encode(self.location, forKey: "geometry.location")
        aCoder.encode(self.placeType.rawValue, forKey: "placeType")
        aCoder.encode(self.placeID, forKey: "placeID")
    }

    public init?(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObject(forKey: "name") as! String
        self.address = aDecoder.decodeObject(forKey: "vicinity") as! String
        self.location = aDecoder.decodeObject(forKey: "geometry.location") as! [String: Float]
        self.isHistory = true
        self.placeType = PlaceType(rawValue: aDecoder.decodeObject(forKey: "placeType") as! String)!
        self.placeID = aDecoder.decodeObject(forKey: "placeID") as! String
    }
    
    // Map
    public required init(unboxer: Unboxer) throws {
        self.name = try unboxer.unbox(key: "name")
        self.address = try unboxer.unbox(key: "vicinity")
        self.location = try unboxer.unbox(keyPath: "geometry.location")
        self.placeID = try unboxer.unbox(key: "place_id")
    }

    // MARK: - Public
    public var iconName: String {
        if self.isHistory { return "history" }
        switch self.placeType {
        case .home:
            return "home"
        case .work:
            return "work"
        case .place:
            return "place"
        }
    }

    public static func ==(lhs: PlaceObj, rhs: PlaceObj) -> Bool {
        if lhs.placeID == rhs.placeID { return true }
        return false
    }
}

