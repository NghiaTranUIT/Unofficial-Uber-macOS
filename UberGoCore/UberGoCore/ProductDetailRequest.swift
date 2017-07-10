//
//  ProductDetailRequest.swift
//  UberGoCore
//
//  Created by Nghia Tran on 7/10/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Alamofire
import CoreLocation
import Foundation
import ObjectMapper

public struct ProductDetailRequestParam: Parameter {

    public let productID: String

    func toDictionary() -> [String: Any] {
        return [:]
    }
}

open class ProductDetailRequest: Requestable {

    // Type
    typealias Element = ProductObj

    // Endpoint
    var endpoint: String {
        guard let param = self.param as? ProductDetailRequestParam else {
            return Constants.UberAPI.ProductDetail
        }
        return Constants.UberAPI.ProductDetail.replacingOccurrences(of: ":id",
                                                                  with: param.productID)
    }

    // HTTP
    var httpMethod: HTTPMethod { return .get }

    // Param
    var param: Parameter? { return _param }
    fileprivate var _param: ProductDetailRequestParam

    // MARK: - Init
    init(_ param: ProductDetailRequestParam) {
        self._param = param
    }

    // MARK: - Decode
    func decode(data: Any) -> Element? {
        guard let result = data as? [String: Any] else {
            return nil
        }
        return Mapper<Element>().map(JSON: result)
    }
}
