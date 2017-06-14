//
//  CancelCurerntTripRequest.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/13/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Alamofire

class CancelCurrentTripRequest: Requestable {

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
    var httpMethod: HTTPMethod { return .delete }

    // Param
    var param: Parameter? { return nil }

    // MARK: - Decode
    func decode(data: Any) -> Element? {
        // This API don't have any response
        return BaseObj()
    }
}
