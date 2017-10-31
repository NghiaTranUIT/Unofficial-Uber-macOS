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

protocol RequestUberViewDelegate: class {

    func requestUberViewShouldShowProductDetail(_ productObj: ProductObj)
}

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
    @IBOutlet fileprivate weak var highFareLbl: NSTextField!

    // MARK: - Variable
    public var viewModel: UberServiceViewModelProtocol! {
        didSet {
            self.binding()
        }
    }
    public weak var delegate: RequestUberViewDelegate?
    fileprivate var isBinding = false
    fileprivate let disposeBag = DisposeBag()
    fileprivate var selectedProduct: Variable<ProductObj?> {
        return viewModel.output.selectedProduct
    }
    fileprivate var selectedGroupProduct: Variable<GroupProductObj?> {
        return viewModel.output.selectedGroupProduct
    }

    // MARK: - Init
    override func awakeFromNib() {
        super.awakeFromNib()

        initCommon()
        initCollectionView()
    }

    // MARK: - Binding
    fileprivate func binding() {

        // Selecte Group
        guard isBinding == false else { return }
        isBinding = true

        // Payment
        updatePaymentMethod()

        // Select Group
        viewModel.output.selectedGroupProduct
            .asObservable()
            .filterNil()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {[weak self] (groupObj) in
                guard let `self` = self else { return }
                self.stackView.arrangedSubviews.forEach({ (btn) in
                    guard let btn = btn as? UberGroupButton else { return }
                    guard let obj = btn.groupObj else { return }
                    // Select
                    if obj === groupObj {
                        btn.state = .on
                    } else {
                        btn.state = .off
                    }
                })
            })
            .disposed(by: disposeBag)

        // Select specific product
        viewModel.output.selectedProduct.asObservable()
            .filterNil()
            .subscribe(onNext: {[weak self] (productObj) in
                guard let `self` = self else {
                    return
                }

                // Stuffs
                self.updatePersonalStuffs(productObj)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Public
    public func configureLayout(_ parentView: NSView) {
        translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(self)
        edges(to: parentView)
    }

    public func updateAvailableGroupProducts(_ groupProductObjs: [GroupProductObj]) {

        // Update Stack
        updateStackView(groupProductObjs)

        // Reload
        collectionView.reloadData()

        // Manually selection
        if groupProductObjs.isEmpty == false {
            collectionView.selectItems(at: Set<IndexPath>(arrayLiteral: IndexPath(item: 0, section: 0)),
                                            scrollPosition: NSCollectionView.ScrollPosition.top)
        }
    }

    // MARK: - Stack View
    fileprivate func updateStackView(_ groupProductObjs: [GroupProductObj]) {

        // Remove all
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        guard groupProductObjs.isEmpty == false else { return }
        // Create
        let groupViews = groupProductObjs.map { UberGroupButton(groupProductObj: $0) }

        // add
        for btn in groupViews {
            btn.delegate = self
            stackView.addArrangedSubview(btn)
        }

        // Default selection at first obj
        if let firstGroup = groupViews.first {
            firstGroup.state = .on
        }
    }

    // MARK: - Payment methods
    fileprivate func updatePaymentMethod() {
        guard let currentUser = UberAuth.share.currentUser else { return }

        // LastUse or select 
        currentUser.currentPaymentAccountObjVar
        .asObservable()
        .filterNil()
        .subscribe(onNext: {[weak self] (accountObj) in
             guard let `self` = self else { return }

            // Layout
            self.paymentImageView.image = NSImage(imageLiteralResourceName: accountObj.type.imageIconName)
            self.cardNumberLbl.stringValue = accountObj.betterAccountDescription
            self.cardNumberLbl.setKern(1.2)
        })
        .disposed(by: disposeBag)
    }

    // MARK: - Stuffs
    fileprivate func updatePersonalStuffs(_ productObj: ProductObj) {

        // Capacity
        seatNumberLnl.stringValue = productObj.prettyCapacity

        // Select Btn
        requestUberBtn.title = "REQUEST \(productObj.displayName)"
        requestUberBtn.setTitleColor(NSColor.white, kern: 2)

        // High Fare
        if let priceObj = productObj.estimatePrice,
            let rate = priceObj.surgeMultiplier,
            rate >= 1.0 {
            highFareLbl.isHidden = false
        } else {
            highFareLbl.isHidden = true
        }
    }

    @IBAction func requestBtnOnTapped(_ sender: Any) {
        viewModel.input.requestUberPublisher.onNext(())
    }

    @IBAction func paymentMethodsOnTap(_ sender: Any) {
        NotificationCenter.postNotificationOnMainThreadType(.showPaymentMethodsView)
    }

}

// MARK: - Private
extension RequestUberView {

    fileprivate func initCommon() {
        backgroundColor = NSColor.black

        requestUberBtn.setTitleColor(NSColor.white, kern: 2)
        cardNumberLbl.textColor = NSColor.black
        seatNumberLnl.textColor = NSColor(hexString: "#989898")
        requestUberBtn.backgroundColor = NSColor.black

        // Border
        scheduleUberBtn.wantsLayer = true
        scheduleUberBtn.layer?.borderColor = NSColor.black.cgColor
        scheduleUberBtn.layer?.borderWidth = 1
        scheduleUberBtn.layer?.cornerRadius = 4
        scheduleUberBtn.layer?.masksToBounds = true

        // Kern
        cardNumberLbl.setKern(1.2)
    }

    fileprivate func initCollectionView() {

        collectionView.dataSource = self
        collectionView.delegate = self

        // Cell
        let nib = NSNib(nibNamed: NSNib.Name(rawValue: "UberProductCell"), bundle: nil)
        collectionView.register(nib, forItemWithIdentifier: NSUserInterfaceItemIdentifier("UberProductCell"))

        // Flow
        let flow = CenterHorizontalFlowLayout()
        collectionView.collectionViewLayout = flow
    }
}

extension RequestUberView: NSCollectionViewDataSource {

    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let group = selectedGroupProduct.value else {
            return 0
        }
        return group.productObjs.count
    }

    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath)
    -> NSCollectionViewItem {
        guard let group = selectedGroupProduct.value else {
            return NSCollectionViewItem()
        }

        let productObj = group.productObjs[indexPath.item]
        guard let cell = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "UberProductCell"), for: indexPath)
            as? UberProductCell else {
            return NSCollectionViewItem()
        }
        cell.delegate = self
        cell.configureCell(with: productObj)

        // Select
        let isSelected = productObj === selectedProduct.value!
        cell.isSelected = isSelected

        return cell
    }

    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let indexPath = indexPaths.first else { return }
        guard let group = selectedGroupProduct.value else { return }

        let obj = group.productObjs[indexPath.item]
        selectedProduct.value = obj
    }
}

// MARK: - NSCollectionViewDelegate
extension RequestUberView: NSCollectionViewDelegate {

}

// MARK: - UberGroupButtonDelegate
extension RequestUberView: UberGroupButtonDelegate {

    func uberGroupButton(_ sender: UberGroupButton, didSelectedGroupObj groupObj: GroupProductObj) {

        // Make selection
        selectedGroupProduct.value = groupObj
        selectedProduct.value = groupObj.productObjs.first!
        collectionView.reloadData()
        collectionView.selectItems(at: Set<IndexPath>(arrayLiteral: IndexPath(item: 0, section: 0)),
                                        scrollPosition: NSCollectionView.ScrollPosition.top)
    }
}

extension RequestUberView: UberProductCellDelegate {

    func uberProductCell(_ sender: UberProductCell, shouldShowProductDetail productObj: ProductObj) {
        delegate?.requestUberViewShouldShowProductDetail(productObj)
    }
}

// MARK: - XIBInitializable
extension RequestUberView: XIBInitializable {
    typealias XibType = RequestUberView
}
