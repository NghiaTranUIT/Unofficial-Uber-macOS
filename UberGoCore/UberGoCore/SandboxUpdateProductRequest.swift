//
//  SandboxUpdateProductRequest.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/20/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Alamofire
import ObjectMapper
import RxSwift

public struct SandboxUpdateProductRequestParam: Parameter {

    public var productID: String?
    public var surgeMultiplier: Float?
    public var driversAvailable: Bool?

    func toDictionary() -> [String : Any] {
        var dict: [String: Any] = [:]
        if let surgeMultiplier = self.surgeMultiplier {
            dict["surge_multiplier"] = surgeMultiplier
        }
        if let driversAvailable = self.driversAvailable {
            dict["drivers_available"] = driversAvailable
        }
        return dict
    }
}

open class SandboxUpdateProductRequest: Requestable {

    // Type
    typealias Element = BaseObj

    // Header
    var addionalHeader: Requestable.HeaderParameter? {
        guard let currentUser = UserObj.currentUser else { return nil }
        guard let token = currentUser.oauthToken else {
            return nil
        }
        let tokenStr = "Bearer " + token
        return ["Authorization": tokenStr]
    }

    // Endpoint
    var endpoint: String {
        guard let param = self.param as? SandboxUpdateProductRequestParam else {
            return Constants.UberAPI.SandboxUpdateProduct
        }
        return Constants.UberAPI.SandboxUpdateProduct.replacingOccurrences(of: ":id",
                                                                         with: param.productID!)
    }

    // HTTP
    var httpMethod: HTTPMethod { return .put }

    // Param
    var param: Parameter? { return self._param }
    fileprivate var _param: SandboxUpdateProductRequestParam

    // MARK: - Init
    init(_ param: SandboxUpdateProductRequestParam) {
        self._param = param
    }

    // MARK: - Decode
    func decode(data: Any) -> Element? {
        guard let result = data as? [String: Any] else {
            return nil
        }
        return Mapper<BaseObj>().map(JSON: result)
    }
}
