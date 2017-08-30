//
//  ReceiptObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 8/17/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Unbox

open class ReceiptObj: Unboxable {

    // MARK: - Variable
    public let requestID: String
    public let totalCharge: String
    public let totalOwed: Float?
    public let totalFare: String
    public let currencyCode: String
    public let chargeAdjustments: [String]
    public let duration: String
    public let distance: String
    public let distanceLabel: String

    // MARK: - Init
    public required init(unboxer: Unboxer) throws {
        requestID = try unboxer.unbox(key: Constants.Object.Receipt.RequestID)
        totalCharge = try unboxer.unbox(key: Constants.Object.Receipt.TotalCharged)
        totalOwed = unboxer.unbox(key: Constants.Object.Receipt.TotalOwed)
        totalFare = try unboxer.unbox(key: Constants.Object.Receipt.TotalFare)
        currencyCode = try unboxer.unbox(key: Constants.Object.Receipt.CurrencyCode)
        chargeAdjustments = try unboxer.unbox(key: Constants.Object.Receipt.ChargeAdjustments)
        duration = try unboxer.unbox(key: Constants.Object.Receipt.Duration)
        distance = try unboxer.unbox(key: Constants.Object.Receipt.Distance)
        distanceLabel = try unboxer.unbox(key: Constants.Object.Receipt.DistanceLabel)
    }
}
