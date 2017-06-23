//
//  NSError+Helper.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/3/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation

extension NSError {

    // Custome message
    static func customMessage(_ message: String) -> NSError {
        let userInfo = [NSLocalizedDescriptionKey: message]
        return NSError(domain: "com.fe.ubergo.defaultError", code: 999, userInfo: userInfo)
    }

    // Unknow error
    static func unknowError() -> NSError {
        let userInfo = [NSLocalizedDescriptionKey: "Unknow error"]
        return NSError(domain: "com.fe.ubergo.defaultError", code: 999, userInfo: userInfo)
    }

    // JSON Mapper Error
    static func jsonMapperError() -> NSError {
        let userInfo = [NSLocalizedDescriptionKey: "JSON Mapper error"]
        return NSError(domain: "com.fe.ubergo.defaultError", code: 998, userInfo: userInfo)
    }

    // Uber Error
    static func uberError(data: Any, code: Int) -> NSError {
        guard let dictData = data as? [String: Any] else {
            return self.jsonMapperError()
        }

        // Incase Uber return many errors
        if let uberErrors = dictData["errors"] as? [[String: Any]] {
            guard let firstError = uberErrors.first else {
                return self.jsonMapperError()
            }
            return NSError(domain: "com.fe.ubergo.defaultError", code: code, userInfo: firstError)
        }

        // Single Error
        return NSError(domain: "com.fe.ubergo.defaultError", code: code, userInfo: dictData)
    }
}
