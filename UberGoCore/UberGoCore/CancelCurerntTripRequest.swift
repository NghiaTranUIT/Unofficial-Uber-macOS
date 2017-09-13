//
//  CancelCurerntTripRequest.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/13/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Alamofire

final class CancelCurrentTripRequest: Request {

    // Type
    typealias Element = Void

    // Endpoint
    var endpoint: String { return Constants.UberAPI.GetCurrentTrip }

    // HTTP
    var httpMethod: HTTPMethod { return .delete }

    // Param
    var param: Parameter? { return nil }

    // MARK: - Decode
    func decode(data: Any) throws -> Element? {
        return nil
    }
}
