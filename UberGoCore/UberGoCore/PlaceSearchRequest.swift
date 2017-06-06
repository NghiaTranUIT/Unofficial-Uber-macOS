//
//  PlaceSearchRequest.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/6/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Alamofire
import Foundation
import ObjectMapper

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
    var param: Parameters? { return self._param }
    fileprivate var _param: Parameters

    // MARK: - Init
    init(param: Parameters) {
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
