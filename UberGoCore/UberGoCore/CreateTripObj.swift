//
//  CreateTripObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/14/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Unbox

open class SurgeConfirmationObj: BaseObj {

    // MARK: - Variable
    public var href: String?
    public var surgeConfirmationId: String?
    public var multiplier: Double?
    public var expiresAt: Double?

    public override func mapping(map: Map) {
        super.mapping(map: map)

        self.href <- map["href"]
        self.surgeConfirmationId <- map["surge_confirmation_id"]
        self.multiplier <- map["multiplier"]
        self.expiresAt <- map["expires_at"]
    }
}

open class CreateTripObj: BaseObj {

    // MARK: - Variable
    public var requestId: String?
    public var productId: String?
    public var status: String?
    public var vehicleObj: VehicleObj?
    public var driverObj: DriverObj?
    public var locationObj: UberCoordinateObj?
    public var eta: Double?
    public var surgeMultiplier: Double?

    // 409 Conflict code
    // Ref: https://developer.uber.com/docs/riders/references/api/v1.2/requests-post#error-responses
    public var surgeConfirmationObj: SurgeConfirmationObj?
    public var errorTitle: String?

    public override func mapping(map: Map) {
        super.mapping(map: map)

        self.requestId <- map["request_id"]
        self.productId <- map["product_id"]
        self.status <- map["status"]
        self.vehicleObj <- map["vehicle"]
        self.driverObj <- map["driver"]
        self.locationObj <- map["location"]
        self.eta <- map["eta"]
        self.surgeMultiplier <- map["surge_multiplier"]

        // 409
        self.surgeConfirmationObj <- map["meta.surge_confirmation"]
        self.errorTitle <- map["errors.0.title"]
    }
}
