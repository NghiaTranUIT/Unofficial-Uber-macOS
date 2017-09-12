//
//  EstimateObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/14/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Unbox

public final class UpFrontFareOb: Unboxable {

    // MARK: - Variable
    public var value: Double
    public var fareId: String
    public var expiresAt: Int
    public var display: String
    public var currencyCode: String

    // MARK: - Init
    public required init(unboxer: Unboxer) throws {
        value = try unboxer.unbox(key: "value")
        fareId = try unboxer.unbox(key: "fare_id")
        expiresAt = try unboxer.unbox(key: "expires_at")
        display = try unboxer.unbox(key: "display")
        currencyCode = try unboxer.unbox(key: "currency_code")
    }
}

public final class FareBreakdownObj: Unboxable {

    // MARK: - Variable
    public var lowAmount: Double
    public var highAmount: Double
    public var displayAmount: String
    public var displayName: String

    public required init(unboxer: Unboxer) throws {
        lowAmount = try unboxer.unbox(key: "low_amount")
        highAmount = try unboxer.unbox(key: "high_amount")
        displayAmount = try unboxer.unbox(key: "display_amount")
        displayName = try unboxer.unbox(key: "display_name")
    }
}

public final class SurgePriceObj: Unboxable {

    // MARK: - Variable
    public var surgeConfirmationHref: String? // Nil before sometime. It's nil for no reason (Tested on Sandbox)
    public var highEstimate: Int
    public var surgeConfirmationId: String
    public var minimum: Int
    public var lowEstimate: Int
    public var fareBreakdownObjs: [FareBreakdownObj]
    public var surgeMultiplier: Float
    public var display: String
    public var currencyCode: String

    static var invalid: SurgePriceObj {
        return SurgePriceObj(surgeConfirmationHref: nil,
                             highEstimate: 0,
                             surgeConfirmationId: "",
                             minimum: 0,
                             lowEstimate: 0,
                             fareBreakdownObjs: [],
                             surgeMultiplier: 0,
                             display: "",
                             currencyCode: "")
    }

    // MARK: - init
    public init(surgeConfirmationHref: String?,
                highEstimate: Int,
                surgeConfirmationId: String, minimum: Int,
                lowEstimate: Int, fareBreakdownObjs: [FareBreakdownObj],
                surgeMultiplier: Float,
                display: String,
                currencyCode: String) {
        self.surgeConfirmationHref = surgeConfirmationHref
        self.highEstimate = highEstimate
        self.surgeConfirmationId = surgeConfirmationId
        self.minimum = minimum
        self.lowEstimate = lowEstimate
        self.fareBreakdownObjs = fareBreakdownObjs
        self.surgeMultiplier = surgeMultiplier
        self.display = display
        self.currencyCode = currencyCode
    }

    public required init(unboxer: Unboxer) throws {
        surgeConfirmationHref = unboxer.unbox(key: "surge_confirmation_href")
        highEstimate = try unboxer.unbox(key: "high_estimate")
        surgeConfirmationId = try unboxer.unbox(key: "surge_confirmation_id")
        minimum = try unboxer.unbox(key: "minimum")
        lowEstimate = try unboxer.unbox(key: "low_estimate")
        fareBreakdownObjs = try unboxer.unbox(key: "fare_breakdown")
        surgeMultiplier = try unboxer.unbox(key: "surge_multiplier")
        display = try unboxer.unbox(key: "display")
        currencyCode = try unboxer.unbox(key: "currency_code")
    }
}

public enum EstimateObjType {
    case upFrontFare
    case surgePrice
    case unknown
}

public final class EstimateObj: Unboxable {

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
        if upFrontFareObj != nil {
            return .upFrontFare
        }
        if surgePriceObj != nil {
            return .surgePrice
        }
        return .unknown
    }

    // MARK: - Init
    public required init(unboxer: Unboxer) throws {
        distanceUnit = try unboxer.unbox(keyPath: "trip.distance_unit")
        durationEstimate = try unboxer.unbox(keyPath: "trip.duration_estimate")
        distanceEstimate = try unboxer.unbox(keyPath: "trip.distance_estimate")
        pickupEstimate = try unboxer.unbox(key: "pickup_estimate")
        upFrontFareObj = unboxer.unbox(key: "fare")
        surgePriceObj = unboxer.unbox(key: "estimate")
    }
}
