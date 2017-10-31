//
//  UberButton.swift
//  UberGo
//
//  Created by Nghia Tran on 6/5/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa

class UberButton: NSButton {

    override func awakeFromNib() {
        super.awakeFromNib()

        // Common
        self.initCommon()
    }

    func setTitleColor(_ color: NSColor, kern: Float? = nil) {

        guard let font = font else {
            return
        }

        // Paragraph
        let style = NSMutableParagraphStyle()
        style.alignment = self.alignment

        // Attribute
        var attributes: [NSAttributedStringKey: Any] =
            [NSAttributedStringKey.foregroundColor: color,
                          NSAttributedStringKey.font: font,
                          NSAttributedStringKey.paragraphStyle: style]

        // Kern
        if let kern = kern {
            attributes[NSAttributedStringKey.kern] = kern
        }

        // Override
        let attributedTitle = NSAttributedString(string: self.title, attributes: attributes)
        self.attributedTitle = attributedTitle
    }

    fileprivate func initCommon() {
    }
}
