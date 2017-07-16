//
//  PlaceSearchRequest.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/6/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Alamofire
import CoreLocation
import Foundation
import Unbox

enum PlaceSearchRequestMode {
    case nearestPlace
    case placeSearchByName
}

public struct PlaceSearchRequestParam: Parameter {

    var keyword: String = ""
    let location: CLLocationCoordinate2D
    var mode = PlaceSearchRequestMode.placeSearchByName

    init(location: CLLocationCoordinate2D) {
        self.mode = PlaceSearchRequestMode.nearestPlace
        self.location = location
    }

    init(keyword: String, location: CLLocationCoordinate2D) {
        self.keyword = keyword
        self.location = location
    }

    func toDictionary() -> [String : Any] {

        switch self.mode {
        case .nearestPlace:
            return ["key": Constants.GoogleApp.Key,
                    "rankby": "distance",
                    "types": "cafe|bank|bar|airport|embassy|school",
                    "location": "\(self.location.latitude),\(self.location.longitude)"]
        case .placeSearchByName:
            return ["keyword": self.keyword,
                    "radius": "20000",
                    "key": Constants.GoogleApp.Key,
                    "location": "\(self.location.latitude),\(self.location.longitude)"]
        }
    }
}

open class PlaceSearchRequest: Requestable {

    // Type
    typealias Element = [PlaceObj]

    // Uber Authen
    var isAuthenticated: Bool { return false }
    
    // Base
    var basePath: String { return Constants.GoogleAPI.BaseURL }

    // Endpoint
    var endpoint: String { return Constants.GoogleAPI.PlaceSearchURL }

    // HTTP
    var httpMethod: HTTPMethod { return .get }

    // Param
    var param: Parameter? { return self._param }
    fileprivate var _param: PlaceSearchRequestParam

    // MARK: - Init
    init(_ param: PlaceSearchRequestParam) {
        self._param = param
    }

    // MARK: - Decode
    func decode(data: Any) throws -> [PlaceObj]? {
        guard let result = data as? [String: Any],
            let places = result["results"] as? [[String: Any]] else {
                return nil
            }
        return try unbox(dictionaries: places)
    }
}
