//
//  PaymentAccountCell.swift
//  UberGo
//
//  Created by Nghia Tran on 6/21/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import UberGoCore

class PaymentAccountCell: NSCollectionViewItem {

    // MARK: - OUTLET
    @IBOutlet fileprivate weak var paymentImageView: NSImageView!
    @IBOutlet fileprivate weak var tickBtn: NSButton!
    @IBOutlet fileprivate weak var cardNumberLbl: UberTextField!
    @IBOutlet fileprivate weak var dividerLineView: NSView!

    // MARK: - Variable
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                self.tickBtn.isHidden = false
            } else {
                self.tickBtn.isHidden = true
            }
        }
    }

    // MARK: - View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initCommon()
    }

    // MARK: - Public
    func configureCell(with account: PaymentAccountObj) {
        self.paymentImageView.image = NSImage(imageLiteralResourceName: account.type.imageIconName)
        self.cardNumberLbl.stringValue = account.betterAccountDescription
        self.cardNumberLbl.setKern(1.2)
    }
}

// MARK: - Private
extension PaymentAccountCell {

    fileprivate func initCommon() {
        self.cardNumberLbl.textColor = NSColor(hexString: "#030303")
        self.view.backgroundColor = NSColor.white
        self.collectionView.backgroundColor = NSColor.white
        self.dividerLineView.backgroundColor = NSColor(hexString: "#ededed")
    }
}
