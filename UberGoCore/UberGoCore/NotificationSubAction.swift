//
//  NotificationSubAction.swift
//  UberGoCore
//
//  Created by Nghia Tran on 8/15/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation

// MARK: - Notification Sub action
protocol NotificationSubAction {

    // Title
    var title: String { get }

    // Deep-url
    var url: String { get }
}
