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
    public var localizedDisplayName: String
    public var estimate: Int
    public var displayName: String
    public var productId: String

    // Time in minutes
    public var prettyEstimateTime: Int {
        return estimate / 60
    }

    // MARK: - Init
    public required init(unboxer: Unboxer) throws {
        self.localizedDisplayName = try unboxer.unbox(key: Constants.Object.TimeEstimate.LocalizedDisplayName)
        self.estimate = try unboxer.unbox(key: Constants.Object.TimeEstimate.Estimate)
        self.displayName = try unboxer.unbox(key: Constants.Object.TimeEstimate.DisplayName)
        self.productId = try unboxer.unbox(key: Constants.Object.TimeEstimate.ProductId)
        try super.init(unboxer: unboxer)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
