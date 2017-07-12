//
//  UberPersonalPlaceObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/8/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation
import Unbox

public enum UberPersonalPlaceType: String {
    case work = "Work"
    case home = "Home"
}

open class UberPersonalPlaceObj: Unboxable {

    // MARK: - Variable
    public var placeType: UberPersonalPlaceType = .work
    public var address: String
    public fileprivate(set) var invalid = false

    // MARK: - Map
    public init(address: String, invalid: Bool = false) {
        self.address = address
    }

    public required init(unboxer: Unboxer) throws {
        self.address = try unboxer.unbox(key: Constants.Object.UberPersonalPlace.Address)
    }
}

// MARK: - Public
extension UberPersonalPlaceObj {

    public static var invalidPlace: UberPersonalPlaceObj {
        return UberPersonalPlaceObj(address: "Invalid", invalid: true)
    }
}
