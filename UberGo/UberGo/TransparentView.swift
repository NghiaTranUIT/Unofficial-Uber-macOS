//
//  IgnoranceView.swift
//  UberGo
//
//  Created by Nghia Tran on 8/3/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import UberGoCore

class TransparentView: NSView {

    override func hitTest(_ point: NSPoint) -> NSView? {
        let subview = super.hitTest(point)

        // Try to ignore transparent view
        if subview === self {
            return nil
        }
        return subview
    }
}
