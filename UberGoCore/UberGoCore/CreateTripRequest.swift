//
//  PostTripRequest.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/14/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Alamofire
import CoreLocation
import ObjectMapper

public struct CreateTripRequestParam: Parameter {

    let fareID: String?
    let productID: String
    let surgeConfirmationId: String?
    let paymentMethodId: String?

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
        var param: [String: Any] = ["product_id": self.productID]

        // Fare ID or Surge_comfirmation
        if let fareID = self.fareID {
             param["fare_id"] = fareID
        }
        if let surgeConfirmationId = self.surgeConfirmationId {
            param["surge_confirmation_id"] = surgeConfirmationId
        }

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

        if let paymentMethodId = self.paymentMethodId {
            param["payment_method_id"] = paymentMethodId
        }

        return param
    }
}

open class CreateTripRequest: Requestable {

    // Type
    typealias Element = CreateTripObj

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
    func decode(data: Any) -> Element? {
        guard let result = data as? [String: Any] else {
            return nil
        }
        return Mapper<CreateTripObj>().map(JSON: result)
    }
}
