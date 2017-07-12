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
    public var value: Double?
    public var fareId: String?
    public var expiresAt: Int?
    public var display: String?
    public var currencyCode: String?

    public override func mapping(map: Map) {
        super.mapping(map: map)

        self.value = try unboxer.unbox(key: "value"]
        self.fareId = try unboxer.unbox(key: "fare_id"]
        self.expiresAt = try unboxer.unbox(key: "expires_at"]
        self.display = try unboxer.unbox(key: "display"]
        self.currencyCode = try unboxer.unbox(key: "currency_code"]
    }
}

open class FareBreakdownObj: BaseObj {

    // MARK: - Variable
    public var lowAmount: Double?
    public var highAmount: Double?
    public var displayAmount: String?
    public var displayName: String?

    public override func mapping(map: Map) {
        super.mapping(map: map)

        self.lowAmount = try unboxer.unbox(key: "low_amount"]
        self.highAmount = try unboxer.unbox(key: "high_amount"]
        self.displayAmount = try unboxer.unbox(key: "display_amount"]
        self.displayName = try unboxer.unbox(key: "display_name"]
    }
}

open class SurgePriceObj: BaseObj {

    // MARK: - Variable
    public var surgeConfirmationHref: String?
    public var highEstimate: Int?
    public var surgeConfirmationId: String?
    public var minimum: Int?
    public var lowEstimate: Int?
    public var fareBreakdownObjs: [FareBreakdownObj]?
    public var surgeMultiplier: Double?
    public var display: String?
    public var currencyCode: String?

    public override func mapping(map: Map) {
        super.mapping(map: map)

        self.surgeConfirmationHref = try unboxer.unbox(key: "surge_confirmation_href")
        self.highEstimate = try unboxer.unbox(key: "high_estimate")
        self.surgeConfirmationId = try unboxer.unbox(key: "surge_confirmation_id")
        self.minimum = try unboxer.unbox(key: "minimum")
        self.lowEstimate = try unboxer.unbox(key: "low_estimate")
        self.fareBreakdownObjs = try unboxer.unbox(key: "fare_breakdown")
        self.surgeMultiplier = try unboxer.unbox(key: "surge_multiplier")
        self.display = try unboxer.unbox(key: "display")
        self.currencyCode = try unboxer.unbox(key: "currency_code")
    }
}

public enum EstimateObjType {
    case upFrontFare
    case surgePrice
    case unknown
}

open class EstimateObj: BaseObj {

    // MARK: - Variable
    public var distanceUnit: String?
    public var durationEstimate: Double?
    public var distanceEstimate: Double?
    public var pickupEstimate: Double?

    // Either
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

    public override func mapping(map: Map) {
        super.mapping(map: map)

        self.distanceUnit = try unboxer.unbox(key: "trip.distance_unit")
        self.durationEstimate = try unboxer.unbox(key: "trip.duration_estimate")
        self.distanceEstimate = try unboxer.unbox(key: "trip.distance_estimate")
        self.pickupEstimate = try unboxer.unbox(key: "pickup_estimate")
        self.upFrontFareObj = try unboxer.unbox(key: "fare")
        self.surgePriceObj = try unboxer.unbox(key: "estimate")
    }

}
