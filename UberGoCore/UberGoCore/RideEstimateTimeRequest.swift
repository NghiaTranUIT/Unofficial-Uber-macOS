//
//  RideEstimateTimeRequest.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/29/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Alamofire
import CoreLocation
import Foundation
import Unbox

struct RideEstimateTimeRequestParam: Parameter {

    let from: PlaceObj
    let productID: String?

    func toDictionary() -> [String: Any] {
        var dict: [String: Any] =  ["start_latitude": self.from.coordinate2D.latitude,
                                    "start_longitude": self.from.coordinate2D.longitude]
        if let productID = self.productID {
            dict["product_id"] = productID
        }
        return dict
    }
}

final class RideEstimateTimeRequest: Request {

    // Type
    typealias Element = [TimeEstimateObj]

    // Endpoint
    var endpoint: String { return Constants.UberAPI.RideEstimateTime }

    // HTTP
    var httpMethod: HTTPMethod { return .get }

    // Param
    var param: Parameter? { return self._param }
    fileprivate var _param: RideEstimateTimeRequestParam

    // MARK: - Init
    init(_ param: RideEstimateTimeRequestParam) {
        self._param = param
    }

    // MARK: - Decode
    func decode(data: Any) throws -> Element? {
        guard let result = data as? [String: Any],
            let products = result["times"] as? [[String: Any]] else {
                return nil
            }
        return try unbox(dictionaries: products)
    }
}
