//
//  PaymentObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/19/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import ObjectMapper

open class PaymentObj: BaseObj {

    // MARK: - Variable
    public var paymentAccountObjs: [PaymentAccountObj]?
    fileprivate var lastUsed: String?

    public var lastUsedPaymentAccount: PaymentAccountObj? {
        guard let paymentAccountObjs = self.paymentAccountObjs else { return nil }
        guard let lastUsed = self.lastUsed else { return nil }

        // Get matched account
        return paymentAccountObjs.first(where: { $0.paymentMethodId! == lastUsed })
    }

    public override func mapping(map: Map) {
        super.mapping(map: map)

        self.paymentAccountObjs <- map[Constants.Object.Payment.PaymentMethods]
        self.lastUsed <- map[Constants.Object.Payment.LastUsed]
    }
}
