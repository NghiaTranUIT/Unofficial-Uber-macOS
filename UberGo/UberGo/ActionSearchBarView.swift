//
//  ActionSearchBarView.swift
//  UberGo
//
//  Created by Nghia Tran on 6/5/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa

class ActionSearchBarView: NSView {

    // MARK: - OUTLET
    @IBOutlet fileprivate weak var dotSquareView: NSView!
    @IBOutlet fileprivate weak var whereToBtn: UberButton!
    @IBOutlet fileprivate weak var verticalBarView: NSView!
    @IBOutlet fileprivate weak var schedulerBtn: NSButton!

    // MARK: - Variable

    // MARK: - Init
    override func awakeFromNib() {
        super.awakeFromNib()

        self.initCommon()
    }

    // MARK: - Action
    @IBAction func whereToBtnOnTap(_ sender: Any) {

    }

    @IBAction func schedulerBtnOnTap(_ sender: Any) {

    }

    func configureView(with parentView: NSView) {

        self.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(self)

        let bottom = NSLayoutConstraint(item: self,
                                     attribute: .bottom,
                                     relatedBy: .equal,
                                     toItem: parentView,
                                     attribute: .bottom,
                                     multiplier: 1,
                                     constant: 0)
        let centerX = NSLayoutConstraint(item: self,
                                        attribute: .centerX,
                                        relatedBy: .equal,
                                        toItem: parentView,
                                        attribute: .centerX,
                                        multiplier: 1,
                                        constant: 0)
        let width = NSLayoutConstraint(item: self,
                                       attribute: .width,
                                       relatedBy: .equal,
                                       toItem: nil, attribute: .notAnAttribute,
                                       multiplier: 1,
                                       constant: 424)
        let height = NSLayoutConstraint(item: self,
                                       attribute: .height,
                                       relatedBy: .equal,
                                       toItem: nil, attribute: .notAnAttribute,
                                       multiplier: 1,
                                       constant: 56)
        parentView.addConstraints([bottom, centerX, height, width])

    }
}

// MARK: - Private
extension ActionSearchBarView {

    fileprivate func initCommon() {

        // Background
        self.backgroundColor = NSColor.white
        self.dotSquareView.backgroundColor = NSColor.black
        self.whereToBtn.updateWhereToBtnAttribute()
        self.verticalBarView.backgroundColor = NSColor(hexString: "#E5E5E5")
    }
}

// MARK: - XIBInitializable
extension ActionSearchBarView: XIBInitializable {
    typealias XibType = ActionSearchBarView
}
