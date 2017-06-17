//
//  RiderObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/13/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation
import ObjectMapper

open class RiderObj: BaseObj {

    // MARK: - Variable
    public var riderId: String?
    public var firstName: String?
    public var me: Bool?

    override public func mapping(map: Map) {
        super.mapping(map: map)

        self.riderId <- map[Constants.Object.Rider.RiderId]
        self.firstName <- map[Constants.Object.Rider.FirstName]
        self.me <- map[Constants.Object.Rider.Me]
    }
}
