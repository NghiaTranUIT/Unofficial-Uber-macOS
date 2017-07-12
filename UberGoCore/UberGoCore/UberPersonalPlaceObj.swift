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

open class UberPersonalPlaceObj: BaseObj {

    // MARK: - Variable
    public var placeType: UberPersonalPlaceType = .work
    public var address: String
    public fileprivate(set) var invalid = false

    // MARK: - Map
    public required init(unboxer: Unboxer) throws {
        self.address = try unboxer.unbox(key: Constants.Object.UberPersonalPlace.Address)
        try super.init(unboxer: unboxer)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
