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
        self.superview?.backgroundColor = self.normalColor
        self.backgroundColor = self.normalColor
        self.focusRingType = .none
    }

    // MARK: - Public
    func setKern(_ kern: Float) {
        guard let font = font else {
            return
        }
        guard let color = self.textColor else {
            return
        }

        // Paragraph
        let style = NSMutableParagraphStyle()
        style.alignment = self.alignment

        // Attribute
        var attributes = [NSForegroundColorAttributeName: color,
                          NSFontAttributeName: font,
                          NSParagraphStyleAttributeName: style] as [String: Any]

        // Kern
        attributes[NSKernAttributeName] = kern

        // Override
        let attributedTitle = NSAttributedString(string: self.stringValue, attributes: attributes)
        self.attributedStringValue = attributedTitle
    }
}
