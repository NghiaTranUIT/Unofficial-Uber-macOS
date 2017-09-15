//
//  MenuView.swift
//  UberGo
//
//  Created by Nghia Tran on 9/15/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa

class MenuView: NSView {

    // MARK: - OUTLET
    @IBOutlet weak var avatarImageView: NSImageView!
    @IBOutlet weak var usernameLbl: NSTextField!
    @IBOutlet weak var startLbl: NSTextField!

    // MARK: - Action
    @IBAction func paymentBtnOnTap(_ sender: NSButton) {
    }

    @IBAction func yourTripBtnOnTap(_ sender: NSButton) {
    }

    @IBAction func helpBtnOnTap(_ sender: NSButton) {
    }

    @IBAction func settingBtnOnTap(_ sender: NSButton) {
    }

    @IBAction func legalBtnOnTap(_ sender: NSButton) {
    }

    // MARK: - Public
}

extension MenuView: XIBInitializable {
    typealias XibType = MenuView
}
