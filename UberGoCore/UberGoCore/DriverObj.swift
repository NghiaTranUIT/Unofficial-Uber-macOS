//
//  DriverObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/13/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation
import ObjectMapper

open class DriverObj: BaseObj {

    // MARK: - Variable
    public var phoneNumber: String?
    public var smsNumber: String?
    public var rating: Int?
    public var pictureUrl: String?
    public var name: String?

    override public func mapping(map: Map) {
        super.mapping(map: map)

        self.phoneNumber <- map[Constants.Object.Driver.PhoneNumber]
        self.smsNumber <- map[Constants.Object.Driver.SmsNumber]
        self.rating <- map[Constants.Object.Driver.Rating]
        self.pictureUrl <- map[Constants.Object.Driver.PictureUrl]
        self.name <- map[Constants.Object.Driver.Name]
    }
}
