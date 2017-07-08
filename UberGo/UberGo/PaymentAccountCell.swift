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
            if isSelected {
                tickBtn.isHidden = false
            } else {
                tickBtn.isHidden = true
            }
        }
    }

    // MARK: - View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        initCommon()
    }

    // MARK: - Public
    func configureCell(with account: PaymentAccountObj) {
        paymentImageView.image = NSImage(imageLiteralResourceName: account.type.imageIconName)
        cardNumberLbl.stringValue = account.betterAccountDescription
        cardNumberLbl.setKern(1.2)
    }
}

// MARK: - Private
extension PaymentAccountCell {

    fileprivate func initCommon() {
        cardNumberLbl.textColor = NSColor(hexString: "#030303")
        view.backgroundColor = NSColor.white
        dividerLineView.backgroundColor = NSColor(hexString: "#ededed")
    }
}
