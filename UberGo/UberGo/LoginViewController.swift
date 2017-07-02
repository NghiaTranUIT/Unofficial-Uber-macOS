//
//  LoginViewController.swift
//  UberGo
//
//  Created by Nghia Tran on 6/2/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa
import UberGoCore

class LoginViewController: BaseViewController {

    // MARK: - OUTLET
    @IBOutlet fileprivate weak var bigTitleLbl: UberTextField!
    @IBOutlet fileprivate weak var subTitleLbl: UberTextField!
    @IBOutlet fileprivate weak var loginBtn: UberButton!

    // MARK: - Variable
    public var viewModel: AuthenticationViewModel!

    // MARK: - View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initCommon()

        // Bind
        self.loginBtn.rx.tap.bind(to: self.viewModel.loginBtnOnTabPublish)
        .addDisposableTo(self.disposeBag)
    }
}

// MARK: - Private
extension LoginViewController {

    fileprivate func initCommon() {

        self.bigTitleLbl.setKern(2.0)
        self.subTitleLbl.textColor = NSColor(hexString: "#1e9399")
        self.subTitleLbl.setKern(2.0)
        self.loginBtn.backgroundColor = NSColor(hexString: "#1e9399")
        self.loginBtn.setTitleColor(NSColor.white, kern: 2.0)
    }
}
