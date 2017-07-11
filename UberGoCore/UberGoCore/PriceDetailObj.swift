//
//  PriceDetailObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 7/10/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import ObjectMapper

open class PriceDetailObj: BaseObj {

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

        self.serviceFees <- map[Constants.Object.PriceDetail.ServiceFees]
        self.costPerMinute <- map[Constants.Object.PriceDetail.CostPerMinute]
        self.distanceUnit <- map[Constants.Object.PriceDetail.DistanceUnit]
        self.minimum <- map[Constants.Object.PriceDetail.Minimum]
        self.costPerDistance <- map[Constants.Object.PriceDetail.CostPerDistance]
        self.base <- map[Constants.Object.PriceDetail.Base]
        self.cancellationFee <- map[Constants.Object.PriceDetail.CancellationFee]
        self.currencyCode <- map[Constants.Object.PriceDetail.CurrencyCode]
    }
}


