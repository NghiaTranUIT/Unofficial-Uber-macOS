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
            guard let obj = selectedAccountObj else { return }
            guard let currentUser = UberAuth.share.currentUser else { return }
            currentUser.selectedNewPaymentObjVar.value = obj
        }
    }

    // MARK: - View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        initCommon()
        initCollectionView()

        // Update
        guard let currentUser = UberAuth.share.currentUser else { return }
        guard let paymentMethod = currentUser.paymentMethodObjVar.value else { return }
        guard let currentAccount = currentUser.currentPaymentAccountObjVar.value else { return }

        // Fill
        paymentObj = paymentMethod
        collectionView.reloadData()

        // Selection
        let paymentAccountObjs = paymentObj.paymentAccountObjs
        var index = 0
        for (i, e) in paymentAccountObjs.enumerated()
            where e.paymentMethodId == currentAccount.paymentMethodId {
            index = i
            break
        }
        let set = Set<IndexPath>([IndexPath(item: index, section: 0)])
        collectionView.selectItems(at: set, scrollPosition: .top)
    }

    @IBAction func exitBtnOnTap(_ sender: Any) {
        delegate?.paymentMethodsControllerShouldDismiss(self)
    }
}

// MARK: - Private
extension PaymentMethodsController {

    fileprivate func initCommon() {
        titileLbl.textColor = NSColor.white
        titileLbl.setKern(2)
    }

    fileprivate func initCollectionView() {

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = false
        collectionView.allowsEmptySelection = false

        // Register
        let nib = NSNib(nibNamed: "PaymentAccountCell", bundle: nil)
        collectionView.register(nib, forItemWithIdentifier: "PaymentAccountCell")

        // Flow
        let flow = SearchCollectionViewFlowLayout()
        flow.itemSize = NSSize(width: collectionView.bounds.width, height: 55)
        collectionView.collectionViewLayout = flow
    }
}

extension PaymentMethodsController: NSCollectionViewDataSource {

    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return paymentObj.paymentAccountObjs.count
    }

    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath)
        -> NSCollectionViewItem {
        // Guard
        guard let cell = collectionView.makeItem(withIdentifier: "PaymentAccountCell", for: indexPath)
            as? PaymentAccountCell else {
                return NSCollectionViewItem()
        }
        let obj = paymentObj.paymentAccountObjs[indexPath.item]
        cell.configureCell(with: obj)

        return cell
    }
}

extension PaymentMethodsController: NSCollectionViewDelegate {

    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let indexPath = indexPaths.first else { return }
        selectedAccountObj = paymentObj.paymentAccountObjs[indexPath.item]
    }
}
