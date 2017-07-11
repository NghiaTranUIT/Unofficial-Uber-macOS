//
//  BreakdownPriceController.swift
//  UberGo
//
//  Created by Nghia Tran on 7/9/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa
import UberGoCore

class BreakdownPriceController: NSViewController {

    // MARK: - Variable
    fileprivate var productObj: ProductObj!

    // MARK: - View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}

// MARK: - Private
extension BreakdownPriceController {

    fileprivate func initCommon() {

    }

    fileprivate func updatePriceDetail() {
        productObj.updatePriceDetail()
    }
}
