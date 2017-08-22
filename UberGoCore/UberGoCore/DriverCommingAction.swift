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
// / Found a UberX driver!                [ Close ]
// / Le Van X 🌟 4.5
// / 🚗 White BMW - 72L7 8614             [ Detail ]
// ------------------------------
//

struct DriverCommingAction: NotificationContent {

    // Action
    var actionType: NotificationActionType { return .driverComming }

    // Content
    var title: String { return "Found a 🚗 UberX driver!" }
    var subTitle: String? { return _subtitle }
    var message: String { return _message }

    // Sub action
    var actions: [NotificationSubAction] {
        return [CloseNotificationSubAction(),
                OpenAppSubAction()]
    }

    // MARK: - Variable
    fileprivate let _subtitle: String
    fileprivate let _message: String

    // MARK: - Init
    init(driver: DriverObj, vehicle: VehicleObj) {
        _subtitle = "\(driver.name) 🌟 \(driver.rating)"
        _message = "🚗 \(vehicle.model) | \(vehicle.licensePlate)"
    }
}
