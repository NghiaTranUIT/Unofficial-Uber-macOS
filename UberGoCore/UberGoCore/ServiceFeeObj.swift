//
//  ServiceFeeObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 7/10/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Unbox

open class ServiceFeeObj: Unboxable {

    // MARK: - Variable
    public var fee: Float
    public var name: String

    // MARK: - Init
    public required init(unboxer: Unboxer) throws {
        fee = try unboxer.unbox(key: Constants.Object.ServiceFee.Fee)
        name = try unboxer.unbox(key: Constants.Object.ServiceFee.Name)
    }

    public init(name: String, fee: Float) {
        self.name = name
        self.fee = fee
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
