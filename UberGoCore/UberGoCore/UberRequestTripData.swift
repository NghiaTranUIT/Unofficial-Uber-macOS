//
//  UberRequestTripData.swift
//  UberGoCore
//
//  Created by Nghia Tran on 8/8/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation

public struct UberRequestTripData {

    public let from: PlaceObj
    public let to: PlaceObj

    public init(from: PlaceObj, to: PlaceObj) {
        self.from = from
        self.to = to
    }
}
