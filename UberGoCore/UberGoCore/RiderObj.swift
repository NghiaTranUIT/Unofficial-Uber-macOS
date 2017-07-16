//
//  RiderObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/13/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation
import Unbox

open class RiderObj: Unboxable {

    // MARK: - Variable
    public var riderId: String?
    public var firstName: String
    public var me: Bool

    // MARK: - Init
    public required init(unboxer: Unboxer) throws {
        riderId = unboxer.unbox(key: Constants.Object.Rider.RiderId)
        firstName = try unboxer.unbox(key: Constants.Object.Rider.FirstName)
        me = try unboxer.unbox(key: Constants.Object.Rider.Me)
    }
}
