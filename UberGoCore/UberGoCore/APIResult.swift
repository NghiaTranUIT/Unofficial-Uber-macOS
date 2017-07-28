//
//  APIResult.swift
//  UberGoCore
//
//  Created by Nghia Tran on 7/23/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation

// Represent the result of Alamofire
// Incooperate flawless with RxSwift
// If we need to handle ERROR in Driver
// Use this one
public enum APIResult<T>: RawRepresentable {

    public typealias RawValue = T

    // Case
    case success(T)
    case error(NSError)

    public init?(rawValue: T) {
        self = .success(rawValue)
    }

    public init(errorValue: Error) {
        self = .error(errorValue as NSError)
    }

    public var rawValue: T {
        switch self {
        case .success(let data):
            return data
        default:
            // There is no way return ERROR which corresponse with <T>
            fatalError("There is no way return ERROR which corresponse with <T>")
        }
    }

    // MARK: - Public
    public var isSucces: Bool {
        switch self {
        case .success:
            return true
        default:
            return false
        }
    }

    public var isError: Bool {
        switch self {
        case .error:
            return true
        default:
            return false
        }
    }

    public var result: T? {
        switch self {
        case .success(let data):
            return data
        default:
            return nil
        }
    }

    public var error: NSError? {
        switch self {
        case .error(let error):
            return error
        default:
            return nil
        }
    }
}
