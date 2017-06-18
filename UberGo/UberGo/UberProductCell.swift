//
//  UberProductCell.swift
//  UberGo
//
//  Created by Nghia Tran on 6/18/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa
import UberGoCore

class UberProductCell: NSCollectionViewItem {

    // MARK: - OUTLET
    @IBOutlet fileprivate weak var productImageView: NSImageView!
    @IBOutlet fileprivate weak var productNameLbl: NSTextField!
    @IBOutlet fileprivate weak var priceLbl: NSTextField!

    // MARK: - Variable
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                self.productImageView.image = NSImage(named: "uber_car_selected")
            } else {
                self.productImageView.image = NSImage(named: "uber_car")
            }
        }
    }

    // MARK: - Init
    override func awakeFromNib() {
        super.awakeFromNib()

        self.isSelected = false

        self.initCommon()
    }

    fileprivate func initCommon() {
        self.productNameLbl.textColor = NSColor.white
        self.priceLbl.textColor = NSColor.white
    }

    // MARK: - Public
    public func configureCell(with productObj: ProductObj) {
        self.productNameLbl.stringValue = productObj.displayName ?? ""

        guard let estimatePrice = productObj.estimatePrice else {
            return
        }

        self.priceLbl.stringValue = estimatePrice.localizedDisplayName ?? "xxx"
    }
}
