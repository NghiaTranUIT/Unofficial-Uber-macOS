//
//  ActionSearchBarView.swift
//  UberGo
//
//  Created by Nghia Tran on 6/5/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa

protocol ActionSearchBarViewDelegate: class {

    func shouldOpenFullSearch()
    func shouldOpenScheduler()
}

class ActionSearchBarView: NSView {

    // MARK: - OUTLET
    @IBOutlet fileprivate weak var dotSquareView: NSView!
    @IBOutlet fileprivate weak var whereToBtn: UberButton!
    @IBOutlet fileprivate weak var verticalBarView: NSView!
    @IBOutlet fileprivate weak var schedulerBtn: NSButton!

    // MARK: - Variable
    weak var delegate: ActionSearchBarViewDelegate?

    // MARK: - Init
    override func awakeFromNib() {
        super.awakeFromNib()

        self.initCommon()
    }

    // MARK: - Action
    @IBAction func whereToBtnOnTap(_ sender: Any) {
        self.delegate?.shouldOpenFullSearch()
    }

    @IBAction func schedulerBtnOnTap(_ sender: Any) {
        self.delegate?.shouldOpenScheduler()
    }

    func configureView(with parentView: NSView) {

        self.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(self)

        self.size(CGSize(width: 424, height: 56))
        self.bottom(to: parentView)
        self.centerX(to: parentView)
    }
}

// MARK: - Private
extension ActionSearchBarView {

    fileprivate func initCommon() {

        // Background
        self.backgroundColor = NSColor.white
        self.dotSquareView.backgroundColor = NSColor.black
        self.whereToBtn.setTitleColor(NSColor(hexString: "#525760"), kern: 2)
        self.verticalBarView.backgroundColor = NSColor(hexString: "#E5E5E5")
    }
}

// MARK: - XIBInitializable
extension ActionSearchBarView: XIBInitializable {
    typealias XibType = ActionSearchBarView
}
