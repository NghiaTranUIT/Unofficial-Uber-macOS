//
//  Request+Default.swift
//  UberGoCore
//
//  Created by Nghia Tran on 9/13/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Alamofire
import Foundation
import RxSwift

// MARK: - Default implementation
extension Request {

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

            Alamofire
                .request(urlRequest)
                .validate(contentType: ["application/json", "text/html"])
                .responseJSON(completionHandler: { (response) in

                    // Validate
                    if let error = self.handleValidation(response) {

                        if error.code == 401 {
                            UberAuth.share.logout()
                        }

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
