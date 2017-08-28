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
    fileprivate var viewModel: AuthenticationViewModelProtocol!

    // MARK: - Init
    public class func buildController(_ coordinator: ViewModelCoordinator) -> LoginViewController {
        let login = LoginViewController(nibName: "LoginViewController", bundle: nil)!
        login.viewModel = coordinator.authenViewModel
        return login
    }

    // MARK: - View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        initCommon()

        // Bind
        loginBtn.rx.tap.bind(to: viewModel.input.loginBtnOnTabPublish)
        .addDisposableTo(disposeBag)
    }
}

// MARK: - Private
extension LoginViewController {

    fileprivate func initCommon() {

        bigTitleLbl.setKern(2.0)
        subTitleLbl.textColor = NSColor(hexString: "#1e9399")
        subTitleLbl.setKern(2.0)
        loginBtn.backgroundColor = NSColor(hexString: "#1e9399")
        loginBtn.setTitleColor(NSColor.white, kern: 2.0)
    }
}
