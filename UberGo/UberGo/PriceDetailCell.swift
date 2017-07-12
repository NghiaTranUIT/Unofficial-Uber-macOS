//
//  PriceDetailCell.swift
//  UberGo
//
//  Created by Nghia Tran on 7/11/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa
import UberGoCore

class PriceDetailCell: NSView {

    // MARK: - Variable
    @IBOutlet weak fileprivate var titleLbl: NSTextField!
    @IBOutlet weak fileprivate var priceLbl: NSTextField!

    // MARK: - View Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        initCommon()
    }

    // MARK: - Public
    public func configureCell(_ feeObj: ServiceFeeObj, currency: String?) {
        titleLbl.stringValue = feeObj.prettyName
        priceLbl.stringValue = feeObj.prettyFeeWithCurrency(currency)
    }
}

// MARK: - Private
extension PriceDetailCell {

    fileprivate func initCommon() {

    }
}

extension PriceDetailCell: XIBInitializable {
    typealias XibType = PriceDetailCell
}
