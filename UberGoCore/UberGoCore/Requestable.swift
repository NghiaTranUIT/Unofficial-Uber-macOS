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

    var isAuthenticated: Bool { get }

    func toObservable() -> Observable<Element>

    func decode(data: Any) -> Element?
}

//
// MARK: - Conform URLConvitible from Alamofire
extension Requestable {
    public func asURLRequest() -> URLRequest {
        return self.buildURLRequest()
    }
}

// MARK: - Default implementation
extension Requestable {

    typealias HeaderParameter = [String: String]
    typealias JSONDictionary = [String: Any]

    var basePath: String { return Constants.UberAPI.BaseSandboxURL }

    var param: Parameter? { return nil }

    var isAuthenticated: Bool { return true }

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
                .validate(contentType: ["application/json", "text/html"])
                .responseJSON(completionHandler: { (response) in

                    guard let _response = response.response else {
                        observer.onError(NSError.jsonMapperError())
                        return
                    }

                    let statusCode = _response.statusCode

                    // 204 - no content
                    if statusCode == 204 {
                        //FIXME : Smell code
                        // Get rid of baseObj
                        // Because sometime, there are no response
                        let base = BaseObj()
                        observer.on(.next(base as! Element))
                        observer.on(.completed)
                        return
                    }

                    // Check Response
                    guard let data = response.result.value else {
                        observer.onError(NSError.jsonMapperError())
                        return
                    }

                    //FIXME : Smell code
                    // Should implement ErrorHandler flawless
                    // Instead of doing manually
                    if statusCode >= 200 && statusCode < 300 {

                        // Parse here
                        guard let result = self.decode(data: data) else {
                            observer.onError(NSError.jsonMapperError())
                            return
                        }

                        // Loger
                        Logger.info(result)

                        // Fill
                        observer.on(.next(result))
                        observer.on(.completed)
                        return
                    }

                    // Error
                    Logger.error(data)
                    let uberError = NSError.uberError(data: data, code: statusCode)
                    observer.onError(uberError)
                })

            return Disposables.create()
        }
    }

    func buildURLRequest() -> URLRequest {

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
