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

enum PersonalPlaceType: String {
    case work
    case home
}

public struct UberPersonalPlaceRequestParam: Parameter {

    let placeType: PersonalPlaceType

    func toDictionary() -> [String : Any] {
        return [:]
    }
}

public class UberPersonalPlaceRequest: Requestable {

    // Type
    typealias Element = UberPersonalPlaceObj

    // Endpoint
    var endpoint: String {
        switch self._param.placeType {
        case .home:
            return Constants.UberAPI.HomePersonalPlace
        case .work:
            return Constants.UberAPI.WorkPseronalPlace
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
    func decode(data: Any) -> Element? {
        guard let result = data as? [String: Any] else {
            return nil
        }
        return try? unbox(dictionary: result)
    }
}
