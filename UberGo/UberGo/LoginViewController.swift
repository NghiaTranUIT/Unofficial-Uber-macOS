//
//  LoginViewController.swift
//  UberGo
//
//  Created by Nghia Tran on 6/2/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa
import UberGoCore

class LoginViewController: NSViewController {

    // MARK: - OUTLET
    @IBOutlet weak var loginBtn: NSButton!

    // MARK: - Variable
    fileprivate var viewModel: AuthenticationViewModel!

    // MARK: - View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    public init?<T: BaseViewModel>(nibName nibNameOrNil: String?, viewModel: T) {
        super.init(nibName: nibNameOrNil, bundle: nil)
        self.viewModel = viewModel as! AuthenticationViewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
