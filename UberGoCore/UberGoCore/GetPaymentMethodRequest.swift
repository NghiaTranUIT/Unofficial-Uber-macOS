//
//  GetPaymentMethodRequest.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/19/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Alamofire
import CoreLocation
import Foundation
import ObjectMapper

class GetPaymentMethodRequest: Requestable {

    // Type
    typealias Element = PaymentObj

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
    var endpoint: String { return Constants.UberAPI.GetPaymentMethod }

    // HTTP
    var httpMethod: HTTPMethod { return .get }

    // Param
    var param: Parameter? { return nil }

    // MARK: - Decode
    func decode(data: Any) -> Element? {
        guard let result = data as? [String: Any] else {
            return nil
        }
        return Mapper<Element>().map(JSON: result)
    }
}
