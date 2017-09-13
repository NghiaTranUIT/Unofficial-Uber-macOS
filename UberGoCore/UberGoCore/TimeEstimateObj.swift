//
//  TimeEstimateObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/29/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation
import Unbox

public final class TimeEstimateObj: Unboxable {

    // MARK: - Variable
    public var localizedDisplayName: String
    public var estimate: Int
    public var displayName: String
    public var productId: String

    // Time in minutes
    public var prettyEstimateTime: String {
        return "\(estimate / 60)"
    }

    // MARK: - Init
    public required init(unboxer: Unboxer) throws {
        localizedDisplayName = try unboxer.unbox(key: Constants.Object.TimeEstimate.LocalizedDisplayName)
        estimate = try unboxer.unbox(key: Constants.Object.TimeEstimate.Estimate)
        displayName = try unboxer.unbox(key: Constants.Object.TimeEstimate.DisplayName)
        productId = try unboxer.unbox(key: Constants.Object.TimeEstimate.ProductId)
    }
}
