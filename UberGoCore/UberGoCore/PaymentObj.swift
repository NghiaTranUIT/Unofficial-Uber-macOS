//
//  PaymentObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/19/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Unbox

open class PaymentObj: BaseObj {

    // MARK: - Variable
    public var paymentAccountObjs: [PaymentAccountObj]
    public var lastUsed: String

    // Last Used
    public var lastUsedPaymentAccount: PaymentAccountObj? {
        return paymentAccountObjs.first(where: { $0.paymentMethodId == lastUsed })
    }

    // MARK: - Init
    public required init(unboxer: Unboxer) throws {
        self.paymentAccountObjs = try unboxer.unbox(key: Constants.Object.Payment.PaymentMethods)
        self.lastUsed = try unboxer.unbox(key: Constants.Object.Payment.LastUsed)
        try super.init(unboxer: unboxer)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
