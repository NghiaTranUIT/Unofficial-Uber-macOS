//
//  UberProductsRequest.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/5/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Alamofire
import CoreLocation
import Foundation
import ObjectMapper

public struct UberProductsRequestParam: Parameter {

    let location: CLLocationCoordinate2D

    func toDictionary() -> [String : Any] {
        return ["latitude": "\(self.location.latitude)",
                "longitude": "\(self.location.longitude)"]
    }
}

public class UberProductsRequest: Requestable {

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
    var param: Parameter? { return self._param }
    fileprivate var _param: UberProductsRequestParam

    // MARK: - Init
    init(_ param: UberProductsRequestParam) {
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