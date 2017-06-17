//
//  PlaceObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/2/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import CoreLocation
import ObjectMapper

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
open class PlaceObj: BaseObj {

    // MARK: - Variable
    public var placeType = PlaceType.place
    public var name: String?
    public var address: String?
    public var coordinate2D: CLLocationCoordinate2D?
    public var location: [String: Float]?
    public var isHistory = false

    // MARK: - Init
    override public init() {
        super.init()
    }

    public init(personalPlaceObj: UberPersonalPlaceObj) {
        super.init()

        self.name = personalPlaceObj.placeType.rawValue
        self.address = personalPlaceObj.address
        self.placeType = PlaceType.fromUberPersonalPlaceType(personalPlaceObj.placeType)
    }

    public override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.address, forKey: "vicinity")
        aCoder.encode(self.location, forKey: "geometry.location")
        aCoder.encode(self.placeType.rawValue, forKey: "placeType")
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.name = aDecoder.decodeObject(forKey: "name") as? String
        self.address = aDecoder.decodeObject(forKey: "vicinity") as? String
        self.location = aDecoder.decodeObject(forKey: "geometry.location") as? [String: Float]
        let lat = Double(self.location!["lat"]!)
        let lng = Double(self.location!["lng"]!)
        self.coordinate2D = CLLocationCoordinate2D(latitude: lat, longitude: lng)

        self.isHistory = true
        self.placeType = PlaceType(rawValue: aDecoder.decodeObject(forKey: "placeType") as! String)!
    }

    public required init?(map: Map) {
        super.init(map: map)
    }

    // Map
    override public func mapping(map: Map) {
        super.mapping(map: map)

        self.name <- map["name"]
        self.address <- map["vicinity"]
        self.location <- map["geometry.location"]
        self.coordinate2D <- (map["geometry.location"], Coordinate2DTransform())
    }

    public var iconName: String {
        if self.isHistory {
            return "history"
        }
        switch self.placeType {
        case .home:
            return "home"
        case .work:
            return "work"
        case .place:
            return "place"
        }
    }
}

extension PlaceObj {

    public static var unknowPlace: PlaceObj {
        let place = PlaceObj()
        place.name = "Unknow location"
        return place
    }
}
