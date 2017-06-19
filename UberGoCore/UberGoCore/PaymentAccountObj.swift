//
//  PaymentAccountObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/19/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import ObjectMapper

public enum PaymentAccountType: String {
    case airtelMoney = "airtel_money"
    case alipay
    case applePay = "apple_pay"
    case americanExpress = "american_express"
    case androidPay = "android_pay"
    case baiduWallet = "baidu_wallet"
    case businessAccount = "business_account"
    case familyAccount = "family_account"
    case cash
    case discover
    case jcb
    case lianlian
    case maestro
    case mastercard
    case paypal
    case paytm
    case ucharge
    case unionpay
    case unknown
    case visa
    case zaakpay

    public var imageIconName: String {
        // For temporary
        // I dont' have any design for particular account type
        return "visa_card"
    }
}

open class PaymentAccountObj: BaseObj {

    // MARK: - Variable
    public var paymentMethodId: String?
    public var typeCode: String?
    public var accountDescription: String?
    public var type: PaymentAccountType {
        guard let code = self.typeCode else {
            return .unknown
        }
        return PaymentAccountType(rawValue: code) ?? .unknown
    }
    public lazy var betterAccountDescription: String = {
        guard let desc = self.accountDescription else {
            return "No description"
        }
        return desc.replacingOccurrences(of: "*", with: "•")
    }()

    public override func mapping(map: Map) {
        super.mapping(map: map)

        self.paymentMethodId <- map[Constants.Object.PaymentAccount.PaymentMethodId]
        self.typeCode <- map[Constants.Object.PaymentAccount.Type]
        self.accountDescription <- map[Constants.Object.PaymentAccount.Description]
    }
}
