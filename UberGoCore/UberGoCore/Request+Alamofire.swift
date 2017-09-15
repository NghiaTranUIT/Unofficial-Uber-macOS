//
//  Request+Alamofire.swift
//  UberGoCore
//
//  Created by Nghia Tran on 9/13/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Alamofire
import Foundation
import RxSwift

//
// MARK: - Conform URLConvitible from Alamofire
extension Request {
    public func asURLRequest() -> URLRequest {
        return self.buildURLRequest()
    }
}

// MARK: - Builder
extension Request {

    fileprivate func buildURLRequest() -> URLRequest {

        // Init
        var request = URLRequest(url: self.url)
        request.httpMethod = self.httpMethod.rawValue
        request.timeoutInterval = TimeInterval(10 * 1000)

        // Encode param
        guard var finalRequest = try? self.parameterEncoding.encode(request, with: self.param?.toDictionary()) else {
            fatalError("Can't handle unknow request")
        }

        // Add addional Header if need
        if let additinalHeaders = self.addionalHeader {
            for (key, value) in additinalHeaders {
                finalRequest.addValue(value, forHTTPHeaderField: key)
            }
        }

        // Add Authentication header
        if isAuthenticated {
            let currentUser = UberAuth.share.currentUser!
            currentUser.authToken.setAuthenticationHeader(request: &finalRequest)
        }

        return finalRequest
    }
}
