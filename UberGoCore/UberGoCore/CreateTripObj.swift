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

        self.href = try unboxer.unbox(key: "href")
        self.surgeConfirmationId = try unboxer.unbox(key: "surge_confirmation_id")
        self.multiplier = try unboxer.unbox(key: "multiplier")
        self.expiresAt = try unboxer.unbox(key: "expires_at")
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

        self.requestId = try unboxer.unbox(key: "request_id")
        self.productId = try unboxer.unbox(key: "product_id")
        self.status = try unboxer.unbox(key: "status")
        self.vehicleObj = try unboxer.unbox(key: "vehicle")
        self.driverObj = try unboxer.unbox(key: "driver")
        self.locationObj = try unboxer.unbox(key: "location")
        self.eta = try unboxer.unbox(key: "eta")
        self.surgeMultiplier = try unboxer.unbox(key: "surge_multiplier")

        // 409
        self.surgeConfirmationObj = try unboxer.unbox(keyPath: "meta.surge_confirmation")
        self.errorTitle = try unboxer.unbox(keyPath: "errors.0.title")
    }
}
