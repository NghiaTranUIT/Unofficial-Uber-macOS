//
//  TimeEstimateObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/29/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation
import Unbox

open class TimeEstimateObj: BaseObj {

    // MARK: - Variable
    public var localizedDisplayName: String?
    public var estimate: Int?
    public var displayName: String?
    public var productId: String?

    // Time in minutes
    public var prettyEstimateTime: Int {
        guard let estimate = estimate else {
            return 5
        }
        return estimate / 60
    }

    override public func mapping(map: Map) {
        super.mapping(map: map)

        self.localizedDisplayName = try unboxer.unbox(key: Constants.Object.TimeEstimate.LocalizedDisplayName)
        self.estimate = try unboxer.unbox(key: Constants.Object.TimeEstimate.Estimate)
        self.displayName = try unboxer.unbox(key: Constants.Object.TimeEstimate.DisplayName)
        self.productId = try unboxer.unbox(key: Constants.Object.TimeEstimate.ProductId)
    }
}
