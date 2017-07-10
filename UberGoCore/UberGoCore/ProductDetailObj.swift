//
//  ProductDetailObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 7/10/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import ObjectMapper

open class ProductDetailObj: BaseObj {

    // MARK: - Variable
    public var serviceFees: [ServiceFeeObj]?
    public var costPerMinute: Float?
    public var distanceUnit: String?
    public var minimum: Float?
    public var costPerDistance: Float?
    public var base: Float?
    public var cancellationFee: Float?
    public var currencyCode: String?

    override public func mapping(map: Map) {
        super.mapping(map: map)

        self.serviceFees <- map[Constants.Object.ProductDetail.ServiceFees]
        self.costPerMinute <- map[Constants.Object.ProductDetail.CostPerMinute]
        self.distanceUnit <- map[Constants.Object.ProductDetail.DistanceUnit]
        self.minimum <- map[Constants.Object.ProductDetail.Minimum]
        self.costPerDistance <- map[Constants.Object.ProductDetail.CostPerDistance]
        self.base <- map[Constants.Object.ProductDetail.Base]
        self.cancellationFee <- map[Constants.Object.ProductDetail.CancellationFee]
        self.currencyCode <- map[Constants.Object.ProductDetail.CurrencyCode]
    }
}


