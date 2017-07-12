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

public struct RideEstimateTimeRequestParam: Parameter {

    let from: CLLocationCoordinate2D
    let productID: String?

    func toDictionary() -> [String : Any] {
        var dict: [String: Any] =  ["start_latitude": self.from.latitude,
                                    "start_longitude": self.from.longitude]
        if let productID = self.productID {
            dict["product_id"] = productID
        }
        return dict
    }
}

class RideEstimateTimeRequest: Requestable {

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
    func decode(data: Any) -> Element? {
        guard let result = data as? [String: Any] else {
            return []
        }
        guard let products = result["times"] as? [[String: Any]] else {
            return []
        }
        return Mapper<TimeEstimateObj>().mapArray(JSONArray: products)
    }
}
