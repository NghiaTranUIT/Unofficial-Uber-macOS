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

    let productId: String

    let startLocation: CLLocationCoordinate2D?
    let endLocation: CLLocationCoordinate2D?
    let startPlaceType: PersonalPlaceType?
    let endPlaceType: PersonalPlaceType?

    func toDictionary() -> [String : Any] {

        if startLocation != nil && startPlaceType != nil {
            fatalError("[Error] Either Start or placeType")
        }

        if endLocation != nil && endPlaceType != nil {
            fatalError("[Error] Either Start or placeType")
        }

        // Param
        var param: [String: Any] = ["product_id": self.productId]

        // Start
        if let placeType = self.startPlaceType {
             param["start_place_id"] = placeType.rawValue
        } else if let startLocation = self.startLocation {
            param["start_latitude"] = startLocation.latitude
            param["start_longitude"] = startLocation.longitude
        }

        // Destination
        if let placeType = self.endPlaceType {
            param["end_place_id"] = placeType.rawValue
        } else if let endLocation = self.endLocation {
            param["end_latitude"] = endLocation.latitude
            param["end_longitude"] = endLocation.longitude
        }

        return param
    }

}

class PostEstimateTripRequest: Requestable {

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
    func decode(data: Any) -> Element? {
        guard let result = data as? [String: Any] else {
            return nil
        }
        return Mapper<EstimateObj>().map(JSON: result)
    }
}
