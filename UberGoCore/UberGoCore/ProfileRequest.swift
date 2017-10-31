//
//  ProfileRequest.swift
//  UberGoCore
//
//  Created by Nghia Tran on 9/17/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Alamofire
import Foundation
import Unbox

final class ProfileRequest: Request {

    // Type
    typealias Element = UserProfileObj

    // Endpoint
    var endpoint: String { return Constants.UberAPI.Profile }

    // HTTP
    var httpMethod: HTTPMethod { return .get }

    // MARK: - Decode
    func decode(data: Any) throws -> Element? {
        guard let result = data as? [String: Any] else {
                return nil
        }
        return try unbox(dictionary: result)
    }
}
