//
//  ServiceFeeObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 7/10/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Unbox

open class ServiceFeeObj: BaseObj {

    // MARK: - Variable
    public var fee: Float
    public var name: String

    // MARK: - Init
    public required init(unboxer: Unboxer) throws {
        self.fee = try unboxer.unbox(key: Constants.Object.ServiceFee.Fee)
        self.name = try unboxer.unbox(key: Constants.Object.ServiceFee.Name)
        try super.init(unboxer: unboxer)
    }

    public override init() {
        super.init()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public class func serviceFee(name: String, fee: Float) -> ServiceFeeObj {
        let obj = ServiceFeeObj()
        obj.name = name
        obj.fee = fee
        return obj
    }

    // MARK: - Public
    public var prettyName: String {
        return name.localizedCapitalized
    }

    public var prettyFee: String {
        return "\(fee)"
    }

    public func prettyFeeWithCurrency(_ currency: String?) -> String {
        if let currency = currency {
            return "\(prettyFee) \(currency)"
        }
        return prettyFee
    }
}
