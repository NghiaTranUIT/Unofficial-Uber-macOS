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

    // Type
    typealias Element = [ProductObj]

    // Header
    var addionalHeader: Requestable.HeaderParameter? {
        guard let currentUser = UserObj.currentUser else { return nil }
        guard let token = currentUser.oauthToken else {
            return nil
        }
        let tokenStr = "Bearer " + token
        return ["Authorization": tokenStr]
    }

    // Endpoint
    var endpoint: String { return Constants.UberAPI.UberProducts }

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
    func decode(data: Any) -> [ProductObj]? {
        guard let result = data as? [String: Any] else {
            return []
        }
        guard let products = result["products"] as? [[String: Any]] else {
            return []
        }
        return Mapper<ProductObj>().mapArray(JSONArray: products)
    }
}
