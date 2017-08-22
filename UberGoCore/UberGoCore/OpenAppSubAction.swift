//
//  OpenAppSubAction.swift
//  UberGoCore
//
//  Created by Nghia Tran on 8/15/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation

struct OpenAppSubAction: NotificationSubAction {

    // URL
    static let OpenAppSubActionURL = "oauth-uber://notification/openapp"

    var subActionType: NotificationSubActionType {
        return .openURL
    }

    var title: String {
        return "Detail"
    }

    var url: String {
        return OpenAppSubAction.OpenAppSubActionURL
    }
}
