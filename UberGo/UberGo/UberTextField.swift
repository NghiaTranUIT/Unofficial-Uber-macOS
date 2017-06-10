//
//  UberTextView.swift
//  UberGo
//
//  Created by Nghia Tran on 6/6/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa

class UberTextField: NSTextField {

    // MARK: - Variable
    fileprivate let selectedColor = NSColor(hexString: "#F9F9F9")
    fileprivate let normalColor = NSColor(hexString: "#EDEDED")

    override func awakeFromNib() {
        super.awakeFromNib()

        self.initCommon()
    }

    fileprivate func initCommon() {

        self.wantsLayer = true
        self.isBordered = false
        self.layer?.masksToBounds = true
        self.layer?.borderWidth = 0

        // Hack
        //FIXME : Upate superview color
        self.superview?.backgroundColor = self.normalColor
        self.backgroundColor = self.normalColor
        self.focusRingType = .none
    }

}
