//
//  UserProfileObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 9/17/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation
import Unbox

public final class UserProfileObj: Unboxable {

    // MARK: - Variable
    public let picture: String
    public let firstName: String
    public let lastName: String
    public let uuid: String
    public let riderId: String
    public let email: String
    public let mobileVerified: Bool
    public let promoCode: String

    // MARK: - Init
    public required init(unboxer: Unboxer) throws {
        picture = try unboxer.unbox(key: Constants.Object.UserProfile.Picture)
        firstName = try unboxer.unbox(key: Constants.Object.UserProfile.FirstName)
        lastName = try unboxer.unbox(key: Constants.Object.UserProfile.LastName)
        uuid = try unboxer.unbox(key: Constants.Object.UserProfile.UUID)
        riderId = try unboxer.unbox(key: Constants.Object.UserProfile.RiderId)
        email = try unboxer.unbox(key: Constants.Object.UserProfile.Email)
        mobileVerified = try unboxer.unbox(key: Constants.Object.UserProfile.MobileVerified)
        promoCode = try unboxer.unbox(key: Constants.Object.UserProfile.PromoCode)
    }
}
