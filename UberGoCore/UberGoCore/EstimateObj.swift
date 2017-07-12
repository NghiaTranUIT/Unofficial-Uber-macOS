//
//  EstimateObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/14/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Unbox

open class UpFrontFareOb: BaseObj {

    // MARK: - Variable
    public var value: Double
    public var fareId: String
    public var expiresAt: Int
    public var display: String
    public var currencyCode: String

    // MARK: - Init
    public required init(unboxer: Unboxer) throws {
        self.value = try unboxer.unbox(key: "value")
        self.fareId = try unboxer.unbox(key: "fare_id")
        self.expiresAt = try unboxer.unbox(key: "expires_at")
        self.display = try unboxer.unbox(key: "display")
        self.currencyCode = try unboxer.unbox(key: "currency_code")
        try super.unboxer(unboxer)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

open class FareBreakdownObj: BaseObj {

    // MARK: - Variable
    public var lowAmount: Double
    public var highAmount: Double
    public var displayAmount: String
    public var displayName: String

    public required init(unboxer: Unboxer) throws {
        self.lowAmount = try unboxer.unbox(key: "low_amount")
        self.highAmount = try unboxer.unbox(key: "high_amount")
        self.displayAmount = try unboxer.unbox(key: "display_amount")
        self.displayName = try unboxer.unbox(key: "display_name")
        try super.init(unboxer: unboxer)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

open class SurgePriceObj: BaseObj {

    // MARK: - Variable
    public var surgeConfirmationHref: String
    public var highEstimate: Int
    public var surgeConfirmationId: String
    public var minimum: Int
    public var lowEstimate: Int
    public var fareBreakdownObjs: [FareBreakdownObj]
    public var surgeMultiplier: Float
    public var display: String
    public var currencyCode: String

    // MARK: - init
    public required init(unboxer: Unboxer) throws {
        self.surgeConfirmationHref = try unboxer.unbox(key: "surge_confirmation_href")
        self.highEstimate = try unboxer.unbox(key: "high_estimate")
        self.surgeConfirmationId = try unboxer.unbox(key: "surge_confirmation_id")
        self.minimum = try unboxer.unbox(key: "minimum")
        self.lowEstimate = try unboxer.unbox(key: "low_estimate")
        self.fareBreakdownObjs = try unboxer.unbox(key: "fare_breakdown")
        self.surgeMultiplier = try unboxer.unbox(key: "surge_multiplier")
        self.display = try unboxer.unbox(key: "display")
        self.currencyCode = try unboxer.unbox(key: "currency_code")
        try super.init(unboxer: unboxer)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

public enum EstimateObjType {
    case upFrontFare
    case surgePrice
    case unknown
}

open class EstimateObj: BaseObj {

    // MARK: - Variable
    public var distanceUnit: String
    public var durationEstimate: Float
    public var distanceEstimate: Float
    public var pickupEstimate: Float

    // Either
    // Depend on current sitation
    // Normal vs surge price
    public var upFrontFareObj: UpFrontFareOb?
    public var surgePriceObj: SurgePriceObj?

    // Type
    public var type: EstimateObjType {
        if self.upFrontFareObj != nil {
            return .upFrontFare
        }
        if self.surgePriceObj != nil {
            return .surgePrice
        }
        return .unknown
    }

    // MARK: - Init
    public required init(unboxer: Unboxer) throws {
        self.distanceUnit = try unboxer.unbox(keyPath: "trip.distance_unit")
        self.durationEstimate = try unboxer.unbox(keyPath: "trip.duration_estimate")
        self.distanceEstimate = try unboxer.unbox(keyPath: "trip.distance_estimate")
        self.pickupEstimate = try unboxer.unbox(key: "pickup_estimate")
        self.upFrontFareObj = unboxer.unbox(key: "fare")
        self.surgePriceObj = unboxer.unbox(key: "estimate")
        try super.init(unboxer: unboxer)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
