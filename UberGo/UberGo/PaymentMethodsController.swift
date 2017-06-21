//
//  PaymentMethodsController.swift
//  UberGo
//
//  Created by Nghia Tran on 6/21/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import UberGoCore

protocol PaymentMethodsControllerDelegate: class {
    func paymentMethodsControllerShouldDismiss(_ sender: PaymentMethodsController)
}

class PaymentMethodsController: NSViewController {

    // MARK: - OUTLET
    @IBOutlet fileprivate weak var exitBtn: UberButton!
    @IBOutlet fileprivate weak var titileLbl: UberTextField!
    @IBOutlet fileprivate weak var collectionView: UberCollectionView!
    @IBOutlet fileprivate weak var topBarView: NSView!

    // MARK: - Variable
    public weak var delegate: PaymentMethodsControllerDelegate?
    fileprivate var paymentObj: PaymentObj!

    // MARK: - View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initCommon()
        self.initCollectionView()
    }

    func configurePayment(_ paymentObj: PaymentObj) {
        self.paymentObj = paymentObj
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

    fileprivate func initCollectionView() {

        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.allowsMultipleSelection = false
        self.collectionView.allowsEmptySelection = false

        // Register
        let nib = NSNib(nibNamed: "PaymentAccountCell", bundle: nil)
        self.collectionView.register(nib, forItemWithIdentifier: "PaymentAccountCell")

        // Flow
        let flow = SearchCollectionViewFlowLayout()
        flow.itemSize = NSSize(width: self.collectionView.bounds.width, height: 55)
        self.collectionView.collectionViewLayout = flow
    }
}

extension PaymentMethodsController: NSCollectionViewDataSource {

    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let accounts = self.paymentObj.paymentAccountObjs else {
            return 0
        }
        return accounts.count
    }

    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        // Guard
        guard let cell = collectionView.makeItem(withIdentifier: "PaymentAccountCell", for: indexPath) as? PaymentAccountCell,
        let accounts = self.paymentObj.paymentAccountObjs else {
                return NSCollectionViewItem()
        }
        let obj = accounts[indexPath.item]
        cell.configureCell(with: obj)
        return cell
    }
}

extension PaymentMethodsController: NSCollectionViewDelegate {

}
