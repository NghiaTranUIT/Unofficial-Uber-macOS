//
//  CancelTripAction.swift
//  UberGoCore
//
//  Created by Nghia Tran on 8/22/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation

// Last trip was finished successful -> Show last price and Open Payment if need
//
// ------------------------------
// / Ops                                        [ Close ]
// / Your trip was cancelled : <                 [ Detail  ]
// ------------------------------
//

struct CancelTripAction: NotificationContent {

    // Action
    var actionType: NotificationActionType { return .cancelByDriver }

    // Content
    var title: String { return "Ops" }
    var message: String { return "Your trip as cancelled :<" }

    // Sub action
    var actions: [NotificationSubAction] {
        return [CloseNotificationSubAction(),
                OpenAppSubAction()]
    }
}
