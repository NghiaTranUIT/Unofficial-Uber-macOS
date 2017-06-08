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
    @IBOutlet fileprivate weak var loginBtn: NSButton!

    // MARK: - Variable
    var viewModel: AuthenticationViewModel!

    // MARK: - View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.loginBtn.rx.tap.bind(to: self.viewModel.loginBtnOnTabPublish)
        .addDisposableTo(self.disposeBag)
    }

    @IBAction func loginBtnOnTap(_ sender: Any) {

    }
}

// MARK: - Private
extension LoginViewController {

    fileprivate func initCommon() {

    }

    fileprivate func initModel() {

    }
}
