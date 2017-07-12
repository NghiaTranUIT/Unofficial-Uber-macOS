//
//  RiderObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/13/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation
import Unbox

open class RiderObj: BaseObj {

    // MARK: - Variable
    public var riderId: String?
    public var firstName: String
    public var me: Bool

    // MARK: - Init
    public required init(unboxer: Unboxer) throws {
        self.riderId = unboxer.unbox(key: Constants.Object.Rider.RiderId)
        self.firstName = try unboxer.unbox(key: Constants.Object.Rider.FirstName)
        self.me = try unboxer.unbox(key: Constants.Object.Rider.Me)
        try super.init(unboxer: unboxer)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
