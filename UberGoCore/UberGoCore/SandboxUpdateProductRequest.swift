//
//  SandboxUpdateProductRequest.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/20/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Alamofire
import RxSwift
import Unbox

struct SandboxUpdateProductRequestParam: Parameter {

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

final class SandboxUpdateProductRequest: Request {

    // Type
    typealias Element = Void

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
    func decode(data: Any) throws -> Element? {
        return nil
    }
}
