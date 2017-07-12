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

        self.value <- map["value"]
        self.fareId <- map["fare_id"]
        self.expiresAt <- map["expires_at"]
        self.display <- map["display"]
        self.currencyCode <- map["currency_code"]
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

        self.lowAmount <- map["low_amount"]
        self.highAmount <- map["high_amount"]
        self.displayAmount <- map["display_amount"]
        self.displayName <- map["display_name"]
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

        self.surgeConfirmationHref <- map["surge_confirmation_href"]
        self.highEstimate <- map["high_estimate"]
        self.surgeConfirmationId <- map["surge_confirmation_id"]
        self.minimum <- map["minimum"]
        self.lowEstimate <- map["low_estimate"]
        self.fareBreakdownObjs <- map["fare_breakdown"]
        self.surgeMultiplier <- map["surge_multiplier"]
        self.display <- map["display"]
        self.currencyCode <- map["currency_code"]
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

        self.distanceUnit <- map["trip.distance_unit"]
        self.durationEstimate <- map["trip.duration_estimate"]
        self.distanceEstimate <- map["trip.distance_estimate"]
        self.pickupEstimate <- map["pickup_estimate"]

        self.upFrontFareObj <- map["fare"]
        self.surgePriceObj <- map["estimate"]
    }

}
