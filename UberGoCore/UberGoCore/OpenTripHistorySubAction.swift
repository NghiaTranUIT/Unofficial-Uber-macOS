//
//  OpenTripHistorySubAction.swift
//  UberGoCore
//
//  Created by Nghia Tran on 8/15/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation

struct OpenTripHistorySubAction: NotificationSubAction {

    static let OpenTripHistorySubActionURL = "oauth-uber://notification/trip_history/"

    var title: String {
        return "Detail"
    }

    var url: String {
        return OpenAppSubAction.OpenAppSubActionURL + requestID
    }

    // MARK: - Variable
    fileprivate let requestID: String

    // MARK: - Init
    init(requestID: String) {
        self.requestID = requestID
    }
}
