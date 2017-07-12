//
//  GetCurrentRequestdRideRequest.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/13/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Alamofire
import CoreLocation
import Foundation
import Unbox

class GetCurrentTripRequest: Requestable {

    // Type
    typealias Element = TripObj

    // Endpoint
    var endpoint: String { return Constants.UberAPI.GetCurrentTrip }

    // HTTP
    var httpMethod: HTTPMethod { return .get }

    // Param
    var param: Parameter? { return nil }

    // MARK: - Decode
    func decode(data: Any) -> Element? {
        guard let result = data as? [String: Any] else {
            return nil
        }
        return Mapper<TripObj>().map(JSON: result)
    }
}
