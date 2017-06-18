//
//  PaymentAccountObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/19/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import ObjectMapper

open class PaymentAccountObj: BaseObj {

    // MARK: - Variable
    public var paymentMethodId: String?
    public var type: String?
    public var accountDescription: String?

    public override func mapping(map: Map) {
        super.mapping(map: map)

        self.paymentMethodId <- map[Constants.Object.PaymentAccount.PaymentMethodId]
        self.type <- map[Constants.Object.PaymentAccount.Type]
        self.accountDescription <- map[Constants.Object.PaymentAccount.Description]
    }
}
