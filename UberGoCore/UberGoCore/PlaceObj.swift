//
//  PlaceObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/2/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa
import ObjectMapper
import CoreLocation

// PlaceType
public enum PlaceType {
    case home
    case work
    case place
    case history

    public var iconName: String {
        switch self {
        case .home:
            return "home"
        case .work:
            return "work"
        case .history:
            return "history"
        case .place:
            return "place"
        }
    }

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
open class PlaceObj: BaseObj {

    // MARK: - Variable
    public var placeType = PlaceType.place
    public var name: String?
    public var address: String?
    public var coordinate2D: CLLocationCoordinate2D?
    public var location: [String: Float]?

    // MARK: - Init
    convenience init(personalPlaceObj: UberPersonalPlaceObj) {
        self.init()

        self.name = personalPlaceObj.placeType.rawValue
        self.address = personalPlaceObj.address
        self.placeType = PlaceType.fromUberPersonalPlaceType(personalPlaceObj.placeType)
    }

    // Map
    override public func mapping(map: Map) {
        super.mapping(map: map)

        self.name <- map["name"]
        self.address <- map["vicinity"]
        self.location <- map["geometry.location"]
        self.coordinate2D <- (map["geometry.location"], Coordinate2DTransform())
    }
}

extension PlaceObj {

    public static var unknowPlace: PlaceObj {
        let place = PlaceObj()
        place.name = "Unknow location"
        return place
    }
}
