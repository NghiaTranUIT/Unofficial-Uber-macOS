//
//  NotificationService.swift
//  UberGoCore
//
//  Created by Nghia Tran on 8/22/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation

protocol UserNotificationServiceProtocol {

    // Publish
    func publishAction(_ action: NotificationContent)
}

open class NotificationService: NSObject {

    // MARK: - Variable

    // MARK: - Init
    override init() {
        super.init()
        NSUserNotificationCenter.default.delegate = self
    }
}

extension NotificationService: UserNotificationServiceProtocol {

    func publishAction(_ action: NotificationContent) {

        // Build action
        let action = action.buildUserNotification()

        // Publish
        NSUserNotificationCenter.default.deliver(action)
    }
}

extension NotificationService: NSUserNotificationCenterDelegate {

    public func userNotificationCenter(_ center: NSUserNotificationCenter,
                                       shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
}
