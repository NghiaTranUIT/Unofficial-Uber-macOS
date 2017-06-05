//
//  ActionSearchBarView.swift
//  UberGo
//
//  Created by Nghia Tran on 6/5/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa

class ActionSearchBarView: NSView {

    // MARK: - Variable


    // MARK: - Init
    override func awakeFromNib() {

    }
}

// MARK: - Private
extension ActionSearchBarView {

    fileprivate func initCommon() {
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.white.cgColor
    }
}

// MARK: - XIBInitializable
extension ActionSearchBarView: XIBInitializable {
    typealias XibType = ActionSearchBarView
}
