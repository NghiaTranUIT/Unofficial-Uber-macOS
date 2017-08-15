//
//  DriverAlreadyNotificationAction.swift
//  UberGoCore
//
//  Created by Nghia Tran on 8/15/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation

// When Driver's already on Pickup
//
// ------------------------------
// / Le Van X is waiting you at [pickup-point]         [ Close ]
// / White BMW - 72L7 8614                             [ Detail ]
// ------------------------------
//

struct DriverAlreadyAction: NotificationContent {

    // Action
    var actionType: NotificationActionType { return .driverAlready }

    // Content
    var title: String { return _title }
    var message: String { return _message }

    // Sub action
    var actions: [NotificationSubAction] {
        return [OpenAppSubAction()]
    }

    // MARK: - Variable
    fileprivate let _title: String
    fileprivate let _message: String

    // MARK: - Init
    init(driver: DriverObj, vehicle: VehicleObj) {
        _title = "\(driver.name) is waiting you at front of entrance 😍"
        _message = "🚗 \(vehicle.model) | \(vehicle.licensePlate)"
    }
}
