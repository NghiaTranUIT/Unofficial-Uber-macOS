//
//  UberAlertView.swift
//  UberGo
//
//  Created by Nghia Tran on 6/27/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa

public typealias UberEmptyBlock = () -> Void

extension NSAlert {

    // MARK: - Public
    public class func confirmationAlertView(showOn window: NSWindow, title: String,
                                            message: String,
                                            okBlock: UberEmptyBlock?,
                                            cancelBlock: UberEmptyBlock?) {

        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        alert.alertStyle = .warning

        alert.beginSheetModal(for: window, completionHandler: { (modalResponse) -> Void in
            if modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn {
                okBlock?()
            } else {
                cancelBlock?()
            }
        })
    }
}
