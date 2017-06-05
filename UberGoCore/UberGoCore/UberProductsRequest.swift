//
//  UberProductsRequest.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/5/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Alamofire
import Foundation
import ObjectMapper

class UberProductsRequest: Requestable {

    typealias Element = [ProductObj]

    var endpoint: String { return Constants.UberAPI.UberProducts }
    var httpMethod: HTTPMethod { return .get }

    func decode(data: Any) -> [ProductObj]? {
        guard let data = data as? [[String: Any]] else {
            return []
        }
        return Mapper<ProductObj>().mapArray(JSONArray: data)
    }
}
