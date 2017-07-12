//
//  PriceObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/2/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Unbox

open class PriceObj: BaseObj {

    // MARK: - Variable
    public var localizedDisplayName: String?
    public var distance: Float?
    public var displayName: String?
    public var productId: String?
    public var highEstimate: Float?
    public var lowEstimate: Float?
    public var duration: Float?
    public var estimate: String?
    public var currencyCode: String?
    public var surgeMultiplier: Double?

    override public func mapping(map: Map) {
        super.mapping(map: map)

        self.localizedDisplayName <- map[Constants.Object.Price.LocalizedDisplayName]
        self.distance <- map[Constants.Object.Price.Distance]
        self.displayName <- map[Constants.Object.Price.DisplayName]
        self.productId <- map[Constants.Object.Price.ProductId]
        self.highEstimate <- map[Constants.Object.Price.HighEstimate]
        self.lowEstimate <- map[Constants.Object.Price.LowEstimate]
        self.duration <- map[Constants.Object.Price.Duration]
        self.estimate <- map[Constants.Object.Price.Estimate]
        self.currencyCode <- map[Constants.Object.Price.CurrencyCode]
        self.surgeMultiplier <- map[Constants.Object.Price.SurgeMultiplier]
    }
}
