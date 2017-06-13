//
//  GetEstimatePriceRequest.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/13/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Alamofire
import CoreLocation
import Foundation
import ObjectMapper

public struct RideEstimatePriceRequestParam: Parameter {

    let originLocation: CLLocationCoordinate2D
    let destinationLocation: CLLocationCoordinate2D

    func toDictionary() -> [String : Any] {
        return ["start_latitude": self.originLocation.latitude,
                "start_longitude": self.originLocation.longitude,
                "end_latitude": self.destinationLocation.latitude,
                "end_longitude": self.destinationLocation.longitude]
    }
}

class RideEstimatePriceRequest: Requestable {

    // Type
    typealias Element = [PriceObj]

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
    var endpoint: String { return Constants.UberAPI.RideEstimatePrice }

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
    func decode(data: Any) -> Element? {
        guard let result = data as? [String: Any] else {
            return []
        }
        guard let products = result["products"] as? [[String: Any]] else {
            return []
        }
        return Mapper<PriceObj>().mapArray(JSONArray: products)
    }
}
