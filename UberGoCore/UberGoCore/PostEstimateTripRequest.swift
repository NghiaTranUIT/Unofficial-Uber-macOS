//
//  PostEstimateRideRequest.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/14/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Alamofire
import CoreLocation
import Unbox

struct PostEstimateTripRequestParamter: Parameter {

    // Require
    fileprivate let productId: String

    // Place
    fileprivate let from: PlaceObj
    fileprivate let to: PlaceObj

    // Init
    public init(productId: String, data: UberRequestTripData) {
        self.productId = productId
        self.from = data.from
        self.to = data.to
    }

    // Build param
    func toDictionary() -> [String: Any] {

        // Param
        var param: [String: Any] = ["product_id": self.productId]

        // Start
        switch from.placeType {
        case .place:
            param["start_latitude"] = from.coordinate2D.latitude
            param["start_longitude"] = from.coordinate2D.longitude
        case .work, .home:
            param["start_place_id"] = from.placeType.rawValue
        }

        // Destination
        switch to.placeType {
        case .place:
            param["end_latitude"] = to.coordinate2D.latitude
            param["end_longitude"] = to.coordinate2D.longitude
        case .work, .home:
            param["end_place_id"] = to.placeType.rawValue
        }

        return param
    }

}

final class PostEstimateTripRequest: Request {

    // Type
    typealias Element = EstimateObj

    // Endpoint
    var endpoint: String { return Constants.UberAPI.RequestEstimate }

    // HTTP
    var httpMethod: HTTPMethod { return .post }

    // Param
    var param: Parameter? { return self._param }
    fileprivate var _param: PostEstimateTripRequestParamter

    // MARK: - Init
    init(_ param: PostEstimateTripRequestParamter) {
        self._param = param
    }

    // MARK: - Decode
    func decode(data: Any) throws -> Element? {
        guard let result = data as? [String: Any] else {
            return nil
        }
        return try unbox(dictionary: result)
    }
}
