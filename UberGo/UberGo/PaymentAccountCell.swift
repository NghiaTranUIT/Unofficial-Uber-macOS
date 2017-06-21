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
    @IBOutlet fileprivate weak var numberLbl: UberTextField!

    // MARK: - View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Public
    func configureCell(with account: PaymentAccountObj) {
        
    }
}
