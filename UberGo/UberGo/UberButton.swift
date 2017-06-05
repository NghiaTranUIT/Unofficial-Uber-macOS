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
    }

    func updateWhereToBtnAttribute() {
        guard let font = font else {
            return
        }

        let style = NSMutableParagraphStyle()
        style.alignment = .left
        let color = NSColor(hexString: "#525760")

        let attributes = [NSForegroundColorAttributeName: color,
                          NSFontAttributeName: font,
                          NSKernAttributeName: 2,
                          NSParagraphStyleAttributeName: style]
            as [String : Any]

        let attributedTitle = NSAttributedString(string: self.title, attributes: attributes)
        self.attributedTitle = attributedTitle
    }
}
