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
    // / Your trip was complete successful                     [ Close ]
    // / Paid 100.000 vnd for 1.5 Km                           [ Show  ]
    // ------------------------------
    //
    case tripSuccessful

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
    var imageName: String { get }
}

// MARK: - Default Implementation NotificationContent
extension NotificationContent {

    // Default sound
    var sound: String {
        return NSUserNotificationDefaultSoundName
    }

    // Default Image
    var imageName: String {
        return ""
    }

    // Sub title
    var subTitle: String? { return nil }

    // Sub actions
    var actions: [NotificationSubAction] {
        return []
    }

    // Build
    func buildUserNotification() -> NSUserNotification {
        let noti = NSUserNotification()

        // Content
        noti.title = title
        noti.subtitle = subTitle
        noti.informativeText = message

        // Sound
        noti.soundName = sound

        // Image
        if let appIconPath = Bundle.allBundles.first!.pathForImageResource("AppIcon") {
            noti.contentImage = NSImage(contentsOfFile: appIconPath)
        }

        // Action
        noti.hasActionButton = !actions.isEmpty

        // Add Buttons
        actions.forEach { (subAction) in
            switch subAction.subActionType {
            case .closeNotification:
                noti.otherButtonTitle = subAction.title

            case .openURL:
                noti.actionButtonTitle = subAction.title
                noti.userInfo = subAction.userInfo
            }
        }
        return noti
    }
}
