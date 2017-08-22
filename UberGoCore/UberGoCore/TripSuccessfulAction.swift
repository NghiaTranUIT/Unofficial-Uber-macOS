//
//  TripSuccessfulAction.swift
//  UberGoCore
//
//  Created by Nghia Tran on 8/15/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation

// Last trip was finished successful -> Show last price and Open Payment if need
//
// ------------------------------
// / Your trip was complete successful                     [ Close ]
// / Paid 100.000 vnd for 1.5 Km                           [ Show  ]
// ------------------------------
//

struct TripSuccessfulAction: NotificationContent {

    // Action
    var actionType: NotificationActionType { return .tripSuccessful }

    // Content
    var title: String { return "Your trip was complete successful 😎" }
    var message: String { return _message }

    // Sub action
    var actions: [NotificationSubAction] {
        return [CloseNotificationSubAction(),
                OpenTripHistorySubAction(requestID: requestID)]
    }

    // MARK: - Variable
    fileprivate let requestID: String
    fileprivate let _message: String

    // MARK: - Init
    init(receipt: ReceiptObj) {
        requestID = receipt.requestID
        _message = "Paid \(receipt.totalCharge) for \(receipt.distance) \(receipt.distanceLabel) 💯"
    }
}
