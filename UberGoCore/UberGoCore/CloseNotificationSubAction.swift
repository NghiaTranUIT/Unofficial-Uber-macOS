//
//  CloseAppSubAction.swift
//  UberGoCore
//
//  Created by Nghia Tran on 8/22/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation

struct CloseNotificationSubAction: NotificationSubAction {

    var subActionType: NotificationSubActionType {
        return .closeNotification
    }

    var title: String {
        return "Close"
    }

    var url: String {
        return ""
    }
}
