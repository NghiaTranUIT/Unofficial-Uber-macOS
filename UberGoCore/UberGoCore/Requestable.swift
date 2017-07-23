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

    func validate(response: DataResponse<Any>?) -> NSError?

    func toObservable() -> Observable<Element>

    func decode(data: Any) throws -> Element?
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

    func validate(response: DataResponse<Any>?) -> NSError? {
        return nil
    }

    func toObservable() -> Observable<Element> {

        return Observable<Element>.create { (observer) -> Disposable in
            guard let urlRequest = try? self.asURLRequest() else {
                observer.on(.error(NSError.unknowError()))
                return Disposables.create {}
            }

            Alamofire
                .request(urlRequest)
                .validate(contentType: ["application/json", "text/html"])
                .responseJSON(completionHandler: { (response) in

                    // Validate
                    if let error = self.handleValidation(response) {
                        Logger.error("[ERROR API] = \(self.endpoint) = \(error)")
                        observer.onError(error)
                        return
                    }

                    // Parse
                    do {
                        guard let result = try self.decode(data: response.result.value!) else {
                            // Void
                            observer.onNext(() as! Element)
                            return
                        }
                        Logger.info(result)
                        observer.onNext(result)
                    } catch let error {
                        Logger.error("[JSON Mapping] = \(self.endpoint) = \(error)")
                        observer.onError(error)
                    }

                    observer.onCompleted()
                    return
                })

            return Disposables.create()
        }
    }
}

// MARK: - Error Hanlding
extension Requestable {

    fileprivate func handleValidation(_ response: DataResponse<Any>?) -> NSError? {

        // No Response
        guard let innerResponse = response?.response else {
            return NSError.jsonMapperError()
        }

        // Default status code
        let statusCode = innerResponse.statusCode

        if 200...300 ~= statusCode {
            return nil
        }

        // Try to optional vaildation from request
        if let error = self.validate(response: response) {
            return error
        }

        return NSError.uberError(data: response?.result.value, code: statusCode)
    }
}

// MARK: - Builder
extension Requestable {

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
