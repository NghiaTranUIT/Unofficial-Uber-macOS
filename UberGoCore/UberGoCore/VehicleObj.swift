//
//  VehicleObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/13/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation
import Unbox

open class VehicleObj: Unboxable {

    // MARK: - Variable
    public var make: String
    public var model: String
    public var licensePlate: String
    public var pictureUrl: String?

    // Fullname
    public var fullName: String {
        return self.make + self.model
    }

    // MARK: - Init
    public required init(unboxer: Unboxer) throws {
        self.make = try unboxer.unbox(key: Constants.Object.Vehicle.Make)
        self.model = try unboxer.unbox(key: Constants.Object.Vehicle.Model)
        self.licensePlate = try unboxer.unbox(key: Constants.Object.Vehicle.LicensePlate)
        self.pictureUrl = unboxer.unbox(key: Constants.Object.Vehicle.PictureUrl)
    }
}
