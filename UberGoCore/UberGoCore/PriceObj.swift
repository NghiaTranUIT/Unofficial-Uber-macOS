//
//  PriceObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/2/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Unbox

public final class PriceObj: Unboxable {

    // MARK: - Variable
    public var localizedDisplayName: String
    public var distance: Float
    public var displayName: String
    public var productId: String
    public var highEstimate: Float?
    public var lowEstimate: Float?
    public var duration: Float
    public var estimate: String
    public var currencyCode: String?
    public var surgeMultiplier: Double?

    // MARK: - Init
    public required init(unboxer: Unboxer) throws {
        localizedDisplayName = try unboxer.unbox(key: Constants.Object.Price.LocalizedDisplayName)
        distance = try unboxer.unbox(key: Constants.Object.Price.Distance)
        displayName = try unboxer.unbox(key: Constants.Object.Price.DisplayName)
        productId = try unboxer.unbox(key: Constants.Object.Price.ProductId)
        highEstimate = unboxer.unbox(key: Constants.Object.Price.HighEstimate)
        lowEstimate = unboxer.unbox(key: Constants.Object.Price.LowEstimate)
        duration = try unboxer.unbox(key: Constants.Object.Price.Duration)
        estimate = try unboxer.unbox(key: Constants.Object.Price.Estimate)
        currencyCode = unboxer.unbox(key: Constants.Object.Price.CurrencyCode)
        surgeMultiplier = try? unboxer.unbox(key: Constants.Object.Price.SurgeMultiplier)
    }
}
