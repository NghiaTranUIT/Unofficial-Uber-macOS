//
//  NotificationSubAction.swift
//  UberGoCore
//
//  Created by Nghia Tran on 8/15/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation

// MARK: - NotificationSubActionType
enum NotificationSubActionType: String {

    // Close notification
    // Title = "Close"
    case closeNotification

    // Do another action
    // Example: Open certain URL
    case openURL
}

// MARK: - Notification Sub action
protocol NotificationSubAction {

    // Type
    var subActionType: NotificationSubActionType { get }

    // Title
    var title: String { get }

    // Deep-url
    var url: String { get }
}

extension NotificationSubAction {

    var userInfo: [String: Any] {
        return ["type": subActionType.rawValue,
                "url": url]
    }
}
