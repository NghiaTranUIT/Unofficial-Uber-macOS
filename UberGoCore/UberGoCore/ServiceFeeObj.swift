//
//  ServiceFeeObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 7/10/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import ObjectMapper

open class ServiceFeeObj: BaseObj {

    // MARK: - Variable
    public var fee: Float?
    public var name: String?

    override public func mapping(map: Map) {
        super.mapping(map: map)

        self.fee <- map[Constants.Object.ServiceFee.Fee]
        self.name <- map[Constants.Object.ServiceFee.Name]
    }
}
