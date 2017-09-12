//
//  PaymentObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/19/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Unbox

public class PaymentObj: Unboxable {

    // MARK: - Variable
    public var paymentAccountObjs: [PaymentAccountObj]
    public var lastUsed: String?

    // Last Used
    public var lastUsedPaymentAccount: PaymentAccountObj? {
        return paymentAccountObjs.first(where: { $0.paymentMethodId == lastUsed })
    }

    // MARK: - Init
    public required init(unboxer: Unboxer) throws {
        paymentAccountObjs = try unboxer.unbox(key: Constants.Object.Payment.PaymentMethods)
        lastUsed = unboxer.unbox(key: Constants.Object.Payment.LastUsed)
    }
}
