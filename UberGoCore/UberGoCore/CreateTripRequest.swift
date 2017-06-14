//
//  PostTripRequest.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/14/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Alamofire
import ObjectMapper

class CreateTripRequest: Requestable {

    // Type
    typealias Element = BaseObj

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
    var endpoint: String { return Constants.UberAPI.GetCurrentTrip }

    // HTTP
    var httpMethod: HTTPMethod { return .patch }

    // Param
    var param: Parameter? { return self._param }
    fileprivate var _param: UpdateCurrentTripRequestParam

    // MARK: - Init
    init(_ param: UpdateCurrentTripRequestParam) {
        self._param = param
    }

    // MARK: - Decode
    func decode(data: Any) -> Element? {
        // This API don't have any response
        return BaseObj()
    }
}
