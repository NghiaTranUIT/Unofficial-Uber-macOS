//
//  PersonalPlaceRequest.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/7/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Alamofire
import CoreLocation
import Foundation
import Unbox

struct UberPersonalPlaceRequestParam: Parameter {

    let placeType: PlaceType

    func toDictionary() -> [String : Any] {
        return [:]
    }
}

final class UberPersonalPlaceRequest: Requestable {

    // Type
    typealias Element = UberPersonalPlaceObj

    // Endpoint
    var endpoint: String {
        switch self._param.placeType {
        case .home:
            return Constants.UberAPI.HomePersonalPlace
        case .work:
            return Constants.UberAPI.WorkPseronalPlace
        case .place:
            fatalError("We don't support place in Uber Personal Place API")
        }
    }

    // HTTP
    var httpMethod: HTTPMethod { return .get }

    // Param
    var param: Parameter? { return self._param }
    fileprivate var _param: UberPersonalPlaceRequestParam

    // MARK: - Init
    init(_ param: UberPersonalPlaceRequestParam) {
        self._param = param
    }

    // MARK: - Decode
    func decode(data: Any) throws -> Element? {
        guard let result = data as? [String: Any] else {
            return nil
        }
        return try unbox(dictionary: result)
    }
}
