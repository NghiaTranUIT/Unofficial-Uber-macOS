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
import ObjectMapper

struct PlaceSearchRequestParam: Parameter {

    let keyword: String
    let radius: String = "20000"
    let key: String
    let location: CLLocationCoordinate2D

    func toDictionary() -> [String : Any] {
        return ["keyword": self.keyword,
                "radius": self.radius,
                "key": Constants.GoogleApp.Key,
                "location": "\(self.location.latitude),\(self.location.longitude)"]
    }
}

class PlaceSearchRequest: Requestable {

    // Type
    typealias Element = [PlaceObj]

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
    func decode(data: Any) -> [PlaceObj]? {
        guard let result = data as? [String: Any] else {
            return []
        }
        guard let places = result["results"] as? [[String: Any]] else {
            return []
        }
        return Mapper<PlaceObj>().mapArray(JSONArray: places)
    }
}
