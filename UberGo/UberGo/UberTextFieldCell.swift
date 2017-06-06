//
//  UberTextFieldCell.swift
//  UberGo
//
//  Created by Nghia Tran on 6/6/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa

class UberTextFieldCell: NSTextFieldCell {

    override func titleRect(forBounds rect: NSRect) -> NSRect {
        var titleRect = super.titleRect(forBounds: rect)

        let minimumHeight = self.cellSize(forBounds: rect).height
        titleRect.origin.y += (titleRect.height - minimumHeight) / 2
        titleRect.size.height = minimumHeight

        return titleRect
    }

    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        super.drawInterior(withFrame: titleRect(forBounds: cellFrame), in: controlView)
    }
}
