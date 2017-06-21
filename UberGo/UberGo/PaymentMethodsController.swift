//
//  PaymentMethodsController.swift
//  UberGo
//
//  Created by Nghia Tran on 6/21/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa

protocol PaymentMethodsControllerDelegate: class {
    func paymentMethodsControllerShouldDismiss(_ sender: PaymentMethodsController)
}

class PaymentMethodsController: NSViewController {

    // MARK: - OUTLET
    @IBOutlet fileprivate weak var exitBtn: UberButton!
    @IBOutlet fileprivate weak var titileLbl: UberTextField!
    @IBOutlet fileprivate weak var collectionView: NSScrollView!
    @IBOutlet fileprivate weak var topBarView: NSView!

    // MARK: - Variable
    public weak var delegate: PaymentMethodsControllerDelegate?

    // MARK: - View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initCommon()
    }

    @IBAction func exitBtnOnTap(_ sender: Any) {
        self.delegate?.paymentMethodsControllerShouldDismiss(self)
    }
}

// MARK: - Private
extension PaymentMethodsController {

    fileprivate func initCommon() {

        self.topBarView.backgroundColor = NSColor.black
        self.titileLbl.textColor = NSColor.white
        self.titileLbl.setKern(2)
    }
}
