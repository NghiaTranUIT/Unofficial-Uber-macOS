//
//  NotificationAction.swift
//  UberGoCore
//
//  Created by Nghia Tran on 8/15/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation

// MARK: - Type action
enum NotificationActionType {

    // Driver cancel the trip purposefully
    case cancelByDriver

    // Last trip was finished successful -> Show last price and Open Payment if need
    //
    // ------------------------------
    // / Your trip was complete successful                [ Close ]
    // / 100.000 vnd via Visa card (by cash, by ...)      [ Show Payment]
    // ------------------------------
    //
    case paymentSuccess

    // Current Trip status change
    case tripStatusChanged

    // When Driver's comming
    //
    // ------------------------------
    // / Found a UberX driver!                [ Close ]
    // / Le Van X 🌟 4.5
    // / 🚗 White BMW - 72L7 8614             [ Detail ]
    // ------------------------------
    //
    case driverComming

    // When Driver's already on Pickup
    //
    // ------------------------------
    // / Le Van X is waiting you at [pickup-point]         [ Close ]
    // / White BMW - 72L7 8614                             [ Detail ]
    // ------------------------------
    //
    case driverAlready

    // No supported!
    case unknown
}

// MARK: - Abstract Notification Content
protocol NotificationContent {

    // Type
    var actionType: NotificationActionType { get }

    // Contents
    var title: String { get }
    var subTitle: String? { get }
    var message: String { get }

    // Actions
    var actions: [NotificationSubAction] { get }

    // Options
    var sound: String { get }
    var shouldOpenApp: Bool { get }
    var openURL: String? { get }
}

// MARK: - Default Implementation NotificationContent
extension NotificationContent {

    // Default sound
    var sound: String {
        return ""
    }

    // Sub title
    var subTitle: String? { return nil }

    // Open app
    var shouldOpenApp: Bool {
        return false
    }

    // No open URL
    var openURL: String? {
        return nil
    }

    // Sub actions
    var actions: [NotificationSubAction] {
        return []
    }
}
