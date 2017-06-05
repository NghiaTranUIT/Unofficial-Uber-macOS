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

    var addionalHeader: Requestable.HeaderParameter? {
        guard let currentUser = UserObj.currentUser else { return nil }
        guard let token = currentUser.oauthToken else {
            return nil
        }
        let tokenStr = "Bearer " + token
        return ["Authorization": tokenStr]
    }
    var endpoint: String { return Constants.UberAPI.UberProducts }
    var httpMethod: HTTPMethod { return .get }
    func decode(data: Any) -> [ProductObj]? {
        guard let result = data as? [String: Any] else {
            return []
        }
        guard let products = result["products"] as? [[String: Any]] else {
            return []
        }
        return Mapper<ProductObj>().mapArray(JSONArray: products)
    }
    var param: Parameters? { return self._param }
    fileprivate var _param: Parameters

    init(param: Parameters) {
        self._param = param
    }
}
