//
//  DriverComming.swift
//  UberGoCore
//
//  Created by Nghia Tran on 8/15/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation

// When Driver's comming
//
// ------------------------------
// / 👨‍✈️ Le Van A - 🌟 4.5                       [ Close ]
// / 🚗 White BMW - 72L7 8614             [ Detail ]
// ------------------------------
//

struct DriverCommingAction: NotificationContent {

    // Action
    var actionType: NotificationActionType { return .driverComming }

    // Content
    var title: String { return _title }
    var message: String { return _message }

    // Sub action
    var actions: [NotificationSubAction] {
        return [CloseNotificationSubAction(),
                OpenAppSubAction()]
    }

    // MARK: - Variable
    fileprivate let _title: String
    fileprivate let _message: String

    // MARK: - Init
    init(driver: DriverObj, vehicle: VehicleObj) {
        _title = "👨‍✈️ \(driver.name) - \(driver.rating) 🌟"
        _message = "🚗 \(vehicle.make) \(vehicle.model) - \(vehicle.licensePlate)"
    }
}
