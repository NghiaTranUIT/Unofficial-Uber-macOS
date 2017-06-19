//
//  RequestUberView.swift
//  UberGo
//
//  Created by Nghia Tran on 6/17/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa
import RxSwift
import UberGoCore

class RequestUberView: NSView {

    // MARK: - OUTLET
    @IBOutlet fileprivate weak var requestUberBtn: UberButton!
    @IBOutlet fileprivate weak var scheduleUberBtn: NSButton!
    @IBOutlet fileprivate weak var paymentImageView: NSButton!
    @IBOutlet fileprivate weak var cardNumberLbl: UberTextField!
    @IBOutlet fileprivate weak var seatNumberLnl: NSTextField!
    @IBOutlet fileprivate weak var dividerLineView: NSView!
    @IBOutlet fileprivate weak var scrollView: NSScrollView!
    @IBOutlet fileprivate weak var collectionView: UberCollectionView!
    @IBOutlet fileprivate weak var stackView: NSStackView!

    // MARK: - Variable
    public let selectedGroupProduct = Variable<GroupProductObj?>(nil)
    public let selectedProduct = Variable<ProductObj?>(nil)

    fileprivate let disposeBag = DisposeBag()

    // MARK: - Init
    override func awakeFromNib() {
        super.awakeFromNib()

        self.initCommon()
        self.initCollectionView()

        self.selectedGroupProduct.asObservable().filterNil()
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: {[weak self] (groupObj) in
            guard let `self` = self else { return }
            self.stackView.arrangedSubviews.forEach({ (btn) in
                guard let btn = btn as? UberGroupButton else { return }
                guard let obj = btn.groupObj else { return }
                // Select
                if obj === groupObj {
                    btn.state = NSOnState
                } else {
                    btn.state = NSOffState
                }
            })
        })
        .addDisposableTo(self.disposeBag)
    }

    // MARK: - Public
    func configureLayout(_ parentView: NSView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(self)

        let top = NSLayoutConstraint(item: self,
                                     attribute: .top,
                                     relatedBy: .equal,
                                     toItem: parentView,
                                     attribute: .top,
                                     multiplier: 1,
                                     constant: 0)
        let left = NSLayoutConstraint(item: self,
                                      attribute: .left,
                                      relatedBy: .equal,
                                      toItem: parentView,
                                      attribute: .left,
                                      multiplier: 1,
                                      constant: 0)
        let right = NSLayoutConstraint(item: self,
                                       attribute: .right,
                                       relatedBy: .equal,
                                       toItem: parentView,
                                       attribute: .right,
                                       multiplier: 1,
                                       constant: 0)
        let bottom = NSLayoutConstraint(item: self,
                                        attribute: .bottom,
                                        relatedBy: .equal,
                                        toItem: parentView, attribute: .bottom,
                                        multiplier: 1,
                                        constant: 0)
        parentView.addConstraints([top, left, right, bottom])
    }

    func updateAvailableGroupProducts(_ groupProductObjs: [GroupProductObj]) {

        // Update Stack
        self.updateStackView(groupProductObjs)

        // Selection
        self.defaultSelection(groupProductObjs)

        // Get Payement methods
        self.updatePaymentMethod()

        // Reload
        self.collectionView.reloadData()
    }

    // MARK: - Stack View
    fileprivate func updateStackView(_ groupProductObjs: [GroupProductObj]) {

        // Remove all
        self.stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Create
        let groupViews = groupProductObjs.map { UberGroupButton(groupProductObj: $0) }

        // add
        groupViews.forEach { [unowned self] (btn) in
            btn.delegate = self
            self.stackView.addArrangedSubview(btn)
        }
    }

    fileprivate func defaultSelection(_ groupProductObjs: [GroupProductObj]) {
        guard let firstGroup = groupProductObjs.first else { return }
        guard let firstProduct = firstGroup.productObjs.first else { return }

        self.selectedGroupProduct.value = firstGroup
        self.selectedProduct.value = firstProduct
    }

    // MARK: - Payment methods
    fileprivate func updatePaymentMethod() {
        guard let currentUser = UserObj.currentUser else { return }

        currentUser.currentPaymentMethodObserver()
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: {[weak self] (paymentObj) in
            guard let `self` = self else { return }

            // No used
            guard let lastUsed = paymentObj.lastUsedPaymentAccount else {
                self.paymentImageView.image = NSImage(named: PaymentAccountType.unknown.imageIconName)
                self.cardNumberLbl.stringValue = "Haven't used yet"
                return
            }

            // Layout
            self.paymentImageView.image = NSImage(named: lastUsed.type.imageIconName)
            self.cardNumberLbl.stringValue = lastUsed.betterAccountDescription 
            self.cardNumberLbl.setKern(1.2)

        }).addDisposableTo(self.disposeBag)
    }
}

// MARK: - Private
extension RequestUberView {

    fileprivate func initCommon() {
        self.backgroundColor = NSColor(hexString: "#343332")
        self.requestUberBtn.backgroundColor = NSColor.white
        self.requestUberBtn.setTitleColor(NSColor.black, kern: 2)
        self.cardNumberLbl.textColor = NSColor.white
        self.scrollView.backgroundColor = NSColor(hexString: "#343332")
        self.collectionView.backgroundColor = NSColor(hexString: "#343332")
        self.seatNumberLnl.textColor = NSColor.white
        self.dividerLineView.backgroundColor = NSColor.white

        // Border
        self.scheduleUberBtn.wantsLayer = true
        self.scheduleUberBtn.layer?.borderColor = NSColor.white.cgColor
        self.scheduleUberBtn.layer?.borderWidth = 1
        self.scheduleUberBtn.layer?.cornerRadius = 4
        self.scheduleUberBtn.layer?.masksToBounds = true

        // Kern
        self.cardNumberLbl.setKern(1.2)
    }

    fileprivate func initCollectionView() {

        self.collectionView.dataSource = self
        self.collectionView.delegate = self

        // Cell
        let nib = NSNib(nibNamed: "UberProductCell", bundle: nil)
        self.collectionView.register(nib, forItemWithIdentifier: "UberProductCell")

        // Flow
        let flow = CenterHorizontalFlowLayout()
        self.collectionView.collectionViewLayout = flow
    }
}

extension RequestUberView: NSCollectionViewDataSource {

    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let group = self.selectedGroupProduct.value else {
            return 0
        }
        return group.productObjs.count
    }

    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath)
    -> NSCollectionViewItem {
        guard let group = self.selectedGroupProduct.value else {
            return NSCollectionViewItem()
        }

        let productObj = group.productObjs[indexPath.item]
        guard let cell = collectionView.makeItem(withIdentifier: "UberProductCell", for: indexPath)
            as? UberProductCell else {
            return NSCollectionViewItem()
        }
        cell.configureCell(with: productObj)

        // Select
        let isSelected = productObj === self.selectedProduct.value!
        cell.isSelected = isSelected

        return cell
    }
}

// MARK: - NSCollectionViewDelegate
extension RequestUberView: NSCollectionViewDelegate {

}

// MARK: - UberGroupButtonDelegate
extension RequestUberView: UberGroupButtonDelegate {

    func uberGroupButton(_ sender: UberGroupButton, didSelectedGroupObj groupObj: GroupProductObj) {

        // Make selection
        self.selectedGroupProduct.value = groupObj
        self.selectedProduct.value = groupObj.productObjs.first!
        self.collectionView.reloadData()
    }
}

// MARK: - XIBInitializable
extension RequestUberView: XIBInitializable {
    typealias XibType = RequestUberView
}
