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
import Unbox

final class GetPaymentMethodRequest: Request {

    // Type
    typealias Element = PaymentObj

    // Endpoint
    var endpoint: String { return Constants.UberAPI.GetPaymentMethod }

    // HTTP
    var httpMethod: HTTPMethod { return .get }

    // Param
    var param: Parameter? { return nil }

    // MARK: - Decode
    func decode(data: Any) throws -> Element? {
        guard let result = data as? [String: Any] else {
            return nil
        }
        return try unbox(dictionary: result)
    }
}
