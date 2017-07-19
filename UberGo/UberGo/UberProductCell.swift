//
//  UberProductCell.swift
//  UberGo
//
//  Created by Nghia Tran on 6/18/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa
import UberGoCore

protocol UberProductCellDelegate: class {
    func uberProductCell(_ sender: UberProductCell, shouldShowProductDetail productObj: ProductObj)
}

class UberProductCell: NSCollectionViewItem {

    // MARK: - OUTLET
    @IBOutlet fileprivate weak var productImageView: NSImageView!
    @IBOutlet fileprivate weak var productNameLbl: NSTextField!
    @IBOutlet fileprivate weak var priceLbl: NSTextField!

    // MARK: - Variable
    fileprivate var productObj: ProductObj!
    weak var delegate: UberProductCellDelegate?
    override var isSelected: Bool {
        didSet {
            if isSelected {
                productImageView.image = NSImage(imageLiteralResourceName: "uber_car_selected")
            } else {
                productImageView.image = NSImage(imageLiteralResourceName: "uber_car")
            }
        }
    }

    // MARK: - Init
    override func awakeFromNib() {
        super.awakeFromNib()

        isSelected = false
        initCommon()
    }

    fileprivate func initCommon() {
        productNameLbl.textColor = NSColor.black
        priceLbl.textColor = NSColor(hexString: "#555555")
    }

    // MARK: - Public
    public func configureCell(with productObj: ProductObj) {
        self.productObj = productObj

        // Name
        productNameLbl.stringValue = productObj.displayName

        // Price
        guard let estimatePrice = productObj.estimatePrice else { return }
        priceLbl.stringValue = estimatePrice.estimate
    }

    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)

        guard isSelected == true else { return }
        delegate?.uberProductCell(self, shouldShowProductDetail: productObj)
    }
}
