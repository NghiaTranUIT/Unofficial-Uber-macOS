//
//  PriceDetailObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 7/10/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Unbox

open class PriceDetailObj: Unboxable {

    // MARK: - Variable
    public var serviceFees: [ServiceFeeObj]
    public var costPerMinute: Float
    public var distanceUnit: String
    public var minimum: Float
    public var costPerDistance: Float
    public var base: Float
    public var cancellationFee: Float
    public var currencyCode: String

    // MARK: - Init
    public required init(unboxer: Unboxer) throws {
        serviceFees = try unboxer.unbox(key: Constants.Object.PriceDetail.ServiceFees)
        costPerMinute = try unboxer.unbox(key: Constants.Object.PriceDetail.CostPerMinute)
        distanceUnit = try unboxer.unbox(key: Constants.Object.PriceDetail.DistanceUnit)
        minimum = try unboxer.unbox(key: Constants.Object.PriceDetail.Minimum)
        costPerDistance = try unboxer.unbox(key: Constants.Object.PriceDetail.CostPerDistance)
        base = try unboxer.unbox(key: Constants.Object.PriceDetail.Base)
        cancellationFee = try unboxer.unbox(key: Constants.Object.PriceDetail.CancellationFee)
        currencyCode = try unboxer.unbox(key: Constants.Object.PriceDetail.CurrencyCode)
    }

    // Get all available services
    // The list isn't always fixed
    public lazy var allAvailableServiceFees: [ServiceFeeObj] = {
        var services: [ServiceFeeObj] = []

        // Base
        services.append(ServiceFeeObj(name: "Base Fare", fee: self.base))
        services.append(ServiceFeeObj(name: "Minimum Fare", fee: self.minimum))
        services.append(ServiceFeeObj(name: "+ Per Minute", fee: self.costPerMinute))
        services.append(ServiceFeeObj(name: "+ Per \(self.distanceUnit)", fee: self.costPerDistance))

        // Append
        services.append(contentsOf: self.serviceFees)
        return services
    }()
}


