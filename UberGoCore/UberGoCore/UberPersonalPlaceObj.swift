//
//  UberPersonalPlaceObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/8/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation
import ObjectMapper

open class UberPersonalPlaceObj: BaseObj {

    // MARK: - Variable
    public var address: String?
    public fileprivate(set) var invalid = false

    // MARK: - Map
    override public func mapping(map: Map) {
        super.mapping(map: map)

        self.address <- map[Constants.Object.UberPersonalPlace.Address]
    }
}

// MARK: - Public
extension UberPersonalPlaceObj {

    public static var invalidPlace: UberPersonalPlaceObj {
        let place = UberPersonalPlaceObj()
        place.invalid = true
        return place
    }
}
