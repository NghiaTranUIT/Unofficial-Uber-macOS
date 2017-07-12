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
open class PlaceObj: BaseObj {

    // MARK: - Variable
    public var placeType = PlaceType.place
    public var name: String?
    public var address: String?
    public var placeID: String?
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
        self.placeID = self.placeType.rawValue
    }

    public override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.address, forKey: "vicinity")
        aCoder.encode(self.location, forKey: "geometry.location")
        aCoder.encode(self.placeType.rawValue, forKey: "placeType")
        aCoder.encode(self.placeID, forKey: "placeID")
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
        self.placeID = aDecoder.decodeObject(forKey: "placeID") as? String
    }
    
    // Map
    public required init(unboxer: Unboxer) throws {
        self.name = try unboxer.unbox(key: "name")
        self.address = try unboxer.unbox(key: "vicinity")
        self.location = try unboxer.unbox(key: "geometry.location")
        self.coordinate2D = try unboxer.unbox(key:"geometry.location")
        self.placeID = try unboxer.unbox(key: "place_id")
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

    override open func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? PlaceObj else {
            return false
        }
        guard let placeID = self.placeID else {
            return false
        }
        guard let _placeID = object.placeID else {
            return false
        }

        if placeID == _placeID {
            return true
        }
        return false
    }
}

extension PlaceObj {

    public static var unknowPlace: PlaceObj {
        let place = PlaceObj()
        place.name = "Unknow location"
        return place
    }
}
