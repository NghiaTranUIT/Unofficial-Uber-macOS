//
//  CreateTripObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/14/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Unbox

open class SurgeConfirmationObj: Unboxable {

    // MARK: - Variable
    public var href: String
    public var surgeConfirmationId: String
    public var multiplier: Float
    public var expiresAt: Float

    // MARK: - Init
    public required init(unboxer: Unboxer) throws {
        self.href = try unboxer.unbox(key: "href")
        self.surgeConfirmationId = try unboxer.unbox(key: "surge_confirmation_id")
        self.multiplier = try unboxer.unbox(key: "multiplier")
        self.expiresAt = try unboxer.unbox(key: "expires_at")
    }
}

open class CreateTripObj: Unboxable {

    // MARK: - Variable
    public var requestId: String
    public var productId: String
    public var status: String
    public var vehicleObj: VehicleObj?
    public var driverObj: DriverObj?
    public var locationObj: UberCoordinateObj?
    public var eta: Float
    public var surgeMultiplier: Float?

    // 409 Conflict code
    // Ref: https://developer.uber.com/docs/riders/references/api/v1.2/requests-post#error-responses
    public var surgeConfirmationObj: SurgeConfirmationObj?
    public var errorTitle: String?

    // MARK: - Init
    public init(requestId: String, productId: String, status: String, eta: Float) {
        self.requestId = requestId
        self.productId = productId
        self.status = status
        self.eta = eta
    }

    public required init(unboxer: Unboxer) throws {
        self.requestId = try unboxer.unbox(key: "request_id")
        self.productId = try unboxer.unbox(key: "product_id")
        self.status = try unboxer.unbox(key: "status")
        self.vehicleObj = unboxer.unbox(key: "vehicle")
        self.driverObj = unboxer.unbox(key: "driver")
        self.locationObj = unboxer.unbox(key: "location")
        self.eta = try unboxer.unbox(key: "eta")
        self.surgeMultiplier = unboxer.unbox(key: "surge_multiplier")

        // 409
        self.surgeConfirmationObj = unboxer.unbox(keyPath: "meta.surge_confirmation")
        self.errorTitle = unboxer.unbox(keyPath: "errors.0.title")
    }

    static var invalid: CreateTripObj {
        return CreateTripObj(requestId: "", productId: "", status: "Unknow", eta: 0)
    }
}
