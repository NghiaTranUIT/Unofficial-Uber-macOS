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
    fileprivate var viewModel: PaymentMethodViewModel!
    public weak var delegate: PaymentMethodsControllerDelegate?
    fileprivate var paymentObj: PaymentObj!
    fileprivate var selectedAccountObj: PaymentAccountObj? {
        didSet {
            guard let obj = self.selectedAccountObj else { return }
            guard let currentUser = UserObj.currentUser else { return }
            currentUser.selectedNewPaymentObjVar.value = obj
        }
    }

    // MARK: - View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initCommon()
        self.initCollectionView()

        // Update
        guard let currentUser = UserObj.currentUser else { return }
        guard let paymentMethod = currentUser.paymentMethodObjVar.value else { return }
        guard let currentAccount = currentUser.currentPaymentAccountObjVar.value else { return }

        // Fill
        self.paymentObj = paymentMethod
        self.collectionView.reloadData()

        // Selection
        guard let paymentAccountObjs = self.paymentObj.paymentAccountObjs else { return }
        var index = 0
        for (i, e) in paymentAccountObjs.enumerated()
            where e.paymentMethodId == currentAccount.paymentMethodId {
            index = i
            break
        }
        let set = Set<IndexPath>([IndexPath(item: index, section: 0)])
        self.collectionView.selectItems(at: set, scrollPosition: .top)
    }

    @IBAction func exitBtnOnTap(_ sender: Any) {
        self.delegate?.paymentMethodsControllerShouldDismiss(self)
    }
}

// MARK: - Private
extension PaymentMethodsController {

    fileprivate func initCommon() {

        self.topBarView.backgroundColor = NSColor.black
        self.collectionView.backgroundColor = NSColor.white
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

    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath)
        -> NSCollectionViewItem {
        // Guard
        guard let cell = collectionView.makeItem(withIdentifier: "PaymentAccountCell", for: indexPath)
            as? PaymentAccountCell,
        let accounts = self.paymentObj.paymentAccountObjs else {
                return NSCollectionViewItem()
        }
        let obj = accounts[indexPath.item]
        cell.configureCell(with: obj)

        return cell
    }
}

extension PaymentMethodsController: NSCollectionViewDelegate {

    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let accounts = self.paymentObj.paymentAccountObjs else { return }
        guard let indexPath = indexPaths.first else { return }
        self.selectedAccountObj = accounts[indexPath.item]
    }
}
