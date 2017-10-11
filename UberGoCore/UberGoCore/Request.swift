//
//  Requestable.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/3/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Alamofire
import Foundation
import RxSwift

typealias HeaderParameter = [String: String]
typealias JSONDictionary = [String: Any]

// MARK: - Request protocol
protocol Request: URLRequestConvertible {

    associatedtype Element

    var basePath: String { get }

    var endpoint: String { get }

    var httpMethod: HTTPMethod { get }

    var param: Parameter? { get }

    var addionalHeader: HeaderParameter? { get }

    var isAuthenticated: Bool { get }

    func decode(data: Any) throws -> Element?
}
