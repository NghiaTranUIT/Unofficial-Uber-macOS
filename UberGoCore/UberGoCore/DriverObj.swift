//
//  DriverObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/13/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation
import Unbox

open class DriverObj: Unboxable {

    // MARK: - Variable
    public var phoneNumber: String
    public var smsNumber: String
    public var rating: Int
    public var pictureUrl: String
    public var name: String

    // MARK: - Init
    public required init(unboxer: Unboxer) throws {
        phoneNumber = try unboxer.unbox(key: Constants.Object.Driver.PhoneNumber)
        smsNumber = try unboxer.unbox(key: Constants.Object.Driver.SmsNumber)
        rating = try unboxer.unbox(key: Constants.Object.Driver.Rating)
        pictureUrl = try unboxer.unbox(key: Constants.Object.Driver.PictureUrl)
        name = try unboxer.unbox(key: Constants.Object.Driver.Name)
    }
}
