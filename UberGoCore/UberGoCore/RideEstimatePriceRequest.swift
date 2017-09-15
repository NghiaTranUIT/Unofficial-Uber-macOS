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

struct RideEstimatePriceRequestParam: Parameter {

    let from: PlaceObj
    let to: PlaceObj

    init(data: UberRequestTripData) {
        self.from = data.from
        self.to = data.to
    }

    func toDictionary() -> [String : Any] {
        return ["start_latitude": self.from.coordinate2D.latitude,
                "start_longitude": self.from.coordinate2D.longitude,
                "end_latitude": self.to.coordinate2D.latitude,
                "end_longitude": self.to.coordinate2D.longitude]
    }
}

final class RideEstimatePriceRequest: Request {

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
    func decode(data: Any) throws -> Element? {
        guard let result = data as? [String: Any],
            let products = result["prices"] as? [[String: Any]] else {
                return nil
            }
        return try unbox(dictionaries: products)
    }
}
