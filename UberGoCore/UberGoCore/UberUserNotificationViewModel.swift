//
//  UberUserNotificationViewModel.swift
//  UberGoCore
//
//  Created by Nghia Tran on 8/22/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation

public protocol UberUserNotificationViewModelProtocol {

    var input: UberUserNotificationViewModelInput { get }
    var output: UberUserNotificationViewModelOutput { get }
}

public protocol UberUserNotificationViewModelInput {

}

public protocol UberUserNotificationViewModelOutput {

}

open class UberUserNotificationViewModel: UberUserNotificationViewModelProtocol,
                                     UberUserNotificationViewModelInput,
                                     UberUserNotificationViewModelOutput {

    // MARK: - Protocol
    public var input: UberUserNotificationViewModelInput { return self }
    public var output: UberUserNotificationViewModelOutput { return self }
}
