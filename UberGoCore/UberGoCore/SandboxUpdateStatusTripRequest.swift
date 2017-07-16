//
//  SandboxUpdateStatusTripRequest.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/23/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Alamofire
import Unbox
import RxSwift

public struct SandboxUpdateStatusTripRequestParam: Parameter {

    var status: TripObjStatus
    var requestID: String

    func toDictionary() -> [String : Any] {
        return ["status": self.status.rawValue]
    }
}

open class SandboxUpdateStatusTripRequest: Requestable {

    // Type
    typealias Element = Void

    // Endpoint
    var endpoint: String {
        guard let param = self.param as? SandboxUpdateStatusTripRequestParam else {
            return Constants.UberAPI.SandboxUpdateStatusTrip
        }
        return Constants.UberAPI.SandboxUpdateStatusTrip.replacingOccurrences(of: ":id",
                                                                           with: param.requestID)
    }

    // HTTP
    var httpMethod: HTTPMethod { return .put }

    // Param
    var param: Parameter? { return self._param }
    fileprivate var _param: SandboxUpdateStatusTripRequestParam

    // MARK: - Init
    init(_ param: SandboxUpdateStatusTripRequestParam) {
        self._param = param
    }

    // MARK: - Decode
    func decode(data: Any) throws -> Element? {
        return nil
    }
}
