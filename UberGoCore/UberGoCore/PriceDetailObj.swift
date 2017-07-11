//
//  PriceDetailObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 7/10/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import ObjectMapper

open class PriceDetailObj: BaseObj {

    // MARK: - Variable
    public var serviceFees: [ServiceFeeObj]?
    public var costPerMinute: Float?
    public var distanceUnit: String?
    public var minimum: Float?
    public var costPerDistance: Float?
    public var base: Float?
    public var cancellationFee: Float?
    public var currencyCode: String?

    // Get all available services
    // The list isn't always fixed
    public lazy var allAvailableServiceFees: [ServiceFeeObj] = {
        var services: [ServiceFeeObj] = []

        // Base
        if let base = self.base {
            services.append(ServiceFeeObj.serviceFee(name: "Base Fare", fee: base))
        }
        if let minimun = self.minimum {
            services.append(ServiceFeeObj.serviceFee(name: "Minimum Fare", fee: minimun))
        }
        if let costPerMinute = self.costPerMinute {
            services.append(ServiceFeeObj.serviceFee(name: "+ Per Minute", fee: costPerMinute))
        }
        if let costPerDistance = self.costPerDistance {
            services.append(ServiceFeeObj.serviceFee(name: "+ Per \(self.distanceUnit ?? "KM")", fee: costPerDistance))
        }

        // Append
        if let fees = self.serviceFees {
            services.append(contentsOf: fees)
        }

        return services
    }()

    override public func mapping(map: Map) {
        super.mapping(map: map)

        self.serviceFees <- map[Constants.Object.PriceDetail.ServiceFees]
        self.costPerMinute <- map[Constants.Object.PriceDetail.CostPerMinute]
        self.distanceUnit <- map[Constants.Object.PriceDetail.DistanceUnit]
        self.minimum <- map[Constants.Object.PriceDetail.Minimum]
        self.costPerDistance <- map[Constants.Object.PriceDetail.CostPerDistance]
        self.base <- map[Constants.Object.PriceDetail.Base]
        self.cancellationFee <- map[Constants.Object.PriceDetail.CancellationFee]
        self.currencyCode <- map[Constants.Object.PriceDetail.CurrencyCode]
    }
}


