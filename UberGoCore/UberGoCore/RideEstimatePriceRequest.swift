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
import Unbox

public struct RideEstimatePriceRequestParam: Parameter {

    let from: CLLocationCoordinate2D
    let to: CLLocationCoordinate2D

    func toDictionary() -> [String : Any] {
        return ["start_latitude": self.from.latitude,
                "start_longitude": self.from.longitude,
                "end_latitude": self.to.latitude,
                "end_longitude": self.to.longitude]
    }
}

class RideEstimatePriceRequest: Requestable {

    // Type
    typealias Element = [PriceObj]

    // Endpoint
    var endpoint: String { return Constants.UberAPI.RideEstimatePrice }

    // HTTP
    var httpMethod: HTTPMethod { return .get }

    // Param
    var param: Parameter? { return self._param }
    fileprivate var _param: RideEstimatePriceRequestParam

    // MARK: - Init
    init(_ param: RideEstimatePriceRequestParam) {
        self._param = param
    }

    // MARK: - Decode
    func decode(data: Any) -> Element? {
        guard let result = data as? [String: Any] else {
            return []
        }
        guard let products = result["prices"] as? [[String: Any]] else {
            return []
        }
        return Mapper<PriceObj>().mapArray(JSONArray: products)
    }
}
