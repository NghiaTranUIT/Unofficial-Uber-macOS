//
//  UberPersonalPlaceObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/8/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation
import Unbox

open class UberPersonalPlaceObj: Unboxable {

    // MARK: - Variable
    public var placeType: PlaceType = .work
    public var address: String
    public fileprivate(set) var invalid = false

    // MARK: - Map
    public init(address: String, invalid: Bool = false) {
        self.address = address
        self.invalid = invalid
    }

    public required init(unboxer: Unboxer) throws {
        address = try unboxer.unbox(key: Constants.Object.UberPersonalPlace.Address)
    }
}

// MARK: - Public
extension UberPersonalPlaceObj {

    public static var invalidPlace: UberPersonalPlaceObj {
        return UberPersonalPlaceObj(address: "Add place", invalid: true)
    }
}
