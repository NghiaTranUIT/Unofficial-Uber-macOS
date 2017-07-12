//
//  DriverObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/13/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation
import Unbox

open class DriverObj: BaseObj {

    // MARK: - Variable
    public var phoneNumber: String
    public var smsNumber: String
    public var rating: Int
    public var pictureUrl: String
    public var name: String

    // MARK: - Init
    public required init(unboxer: Unboxer) throws {
        self.phoneNumber = try unboxer.unbox(key: Constants.Object.Driver.PhoneNumber)
        self.smsNumber = try unboxer.unbox(key: Constants.Object.Driver.SmsNumber)
        self.rating = try unboxer.unbox(key: Constants.Object.Driver.Rating)
        self.pictureUrl = try unboxer.unbox(key: Constants.Object.Driver.PictureUrl)
        self.name = try unboxer.unbox(key: Constants.Object.Driver.Name)
        try super.init(unboxer: unboxer)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
