//
//  PostTripRequest.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/14/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Alamofire
import CoreLocation
import Unbox

public struct CreateTripRequestParam: Parameter {

    // Require
    let fareID: String?
    let productID: String
    let surgeConfirmationId: String?
    let paymentMethodId: String?

    // Coordinate
    let from: PlaceObj
    let to: PlaceObj

    // Init
    init(fareID: String?,
         productID: String,
         surgeConfirmationId: String?,
         paymentMethodId: String?,
         data: UberRequestTripData) {
        self.fareID = fareID
        self.productID = productID
        self.surgeConfirmationId = surgeConfirmationId
        self.paymentMethodId = paymentMethodId
        self.from = data.from
        self.to = data.to
    }

    func toDictionary() -> [String: Any] {

        // Param
        var param: [String: Any] = ["product_id": self.productID]

        // Fare ID or Surge_comfirmation
        if let fareID = self.fareID {
             param["fare_id"] = fareID
        }
        if let surgeConfirmationId = self.surgeConfirmationId {
            param["surge_confirmation_id"] = surgeConfirmationId
        }

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

        // Payment
        if let paymentMethodId = self.paymentMethodId {
            param["payment_method_id"] = paymentMethodId
        }

        return param
    }
}

final class CreateTripRequest: Request {

    // Type
    typealias Element = CreateTripObj

    // Endpoint
    var endpoint: String { return Constants.UberAPI.CreateTripRequest }

    // HTTP
    var httpMethod: HTTPMethod { return .post }

    // Param
    var param: Parameter? { return self._param }
    fileprivate var _param: CreateTripRequestParam

    // MARK: - Init
    init(_ param: CreateTripRequestParam) {
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
