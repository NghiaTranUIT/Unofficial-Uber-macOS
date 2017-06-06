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

// MARK: - Request protocol
protocol Requestable: URLRequestConvertible {

    associatedtype Element

    var basePath: String { get }

    var endpoint: String { get }

    var httpMethod: HTTPMethod { get }

    var param: Parameter? { get }

    var addionalHeader: HeaderParameter? { get }

    var parameterEncoding: ParameterEncoding { get }

    func toObservable() -> Observable<Element>

    func decode(data: Any) -> Element?
}

//
// MARK: - Conform URLConvitible from Alamofire
extension Requestable {
    func asURLRequest() -> URLRequest {
        return self.buildURLRequest()
    }
}

// MARK: - Default implementation
extension Requestable {

    typealias HeaderParameter = [String: String]
    typealias JSONDictionary = [String: Any]

    var basePath: String { return Constants.UberAPI.BaseURL }

    var param: Parameter? { return nil }

    var addionalHeader: HeaderParameter? { return nil }

    var defaultHeader: HeaderParameter { return ["Accept": "application/json", "Accept-Language": "en_US"] }

    var urlPath: String { return basePath + endpoint }

    var url: URL { return URL(string: urlPath)! }

    var parameterEncoding: ParameterEncoding {
        if self.httpMethod == .get {
            return URLEncoding.default
        }
        return JSONEncoding.default
    }

    func toObservable() -> Observable<Element> {

        return Observable<Element>.create { (observer) -> Disposable in

            guard let urlRequest = try? self.asURLRequest() else {
                observer.on(.error(NSError.unknowError()))
                return Disposables.create {}
            }

            Alamofire.request(urlRequest)
                .validate(statusCode: 200..<300)
                .validate(contentType: ["application/json"])
                .responseJSON(completionHandler: { (response) in

                    // Check error
                    if let error = response.result.error {
                        observer.onError(error)
                        return
                    }

                    // Check Response
                    guard let data = response.result.value else {
                        observer.onError(NSError.jsonMapperError())
                        return
                    }

                    // Parse here
                    guard let result = self.decode(data: data) else {
                        observer.onError(NSError.jsonMapperError())
                        return
                    }

                    // Fill
                    observer.on(.next(result))
                    observer.on(.completed)
                })

            return Disposables.create()
        }
    }

    func buildURLRequest() -> URLRequest {

        // Init
        var urlRequest = URLRequest(url: self.url)
        urlRequest.httpMethod = self.httpMethod.rawValue
        urlRequest.timeoutInterval = TimeInterval(10 * 1000)

        // Encode param
        guard var request = try? self.parameterEncoding.encode(urlRequest, with: self.param?.toDictionary()) else {
            fatalError("Can't handle unknow request")
        }

        // Add addional Header if need
        if let additinalHeaders = self.addionalHeader {
            for (key, value) in additinalHeaders {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }

        return request
    }
}
