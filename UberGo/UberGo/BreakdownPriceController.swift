//
//  BreakdownPriceController.swift
//  UberGo
//
//  Created by Nghia Tran on 7/9/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa
import RxSwift
import UberGoCore

class BreakdownPriceController: NSViewController {

    // MARK: - OUTLET
    @IBOutlet weak fileprivate var titleLbl: UberTextField!
    @IBOutlet weak fileprivate var descriptionLbl: NSTextField!
    @IBOutlet weak fileprivate var stackView: NSStackView!
    
    // MARK: - Variable
    fileprivate var productObj: ProductObj!
    fileprivate var disposeBag = DisposeBag()

    // MARK: - View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        initCommon()
        setupData()
    }

    // MARK: - Public
    public func configureController(_ productObj: ProductObj) {
        self.productObj = productObj
    }
    @IBAction func exitBtnOnTap(_ sender: Any) {
        presenting?.dismissViewController(self)
    }
}

// MARK: - Private
extension BreakdownPriceController {

    fileprivate func initCommon() {
        titleLbl.setKern(2)
    }

    fileprivate func setupData() {
        productObj.updatePriceDetail()

        // Setup if data available
        if let priceObj = productObj.priceDetailVariable.value {
            setupStackView(priceObj)
            return
        }

        // Observe
        productObj.priceDetailVariable.asDriver()
            .filterNil()
            .drive(onNext: {[weak self] (priceObj) in
                guard let `self` = self else { return }
                self.setupStackView(priceObj)
            })
            .addDisposableTo(disposeBag)
    }

    fileprivate func setupStackView(_ priceObj: PriceDetailObj) {

        // Remove all
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Data
        let services = priceObj.allAvailableServiceFees

        // Create
        let groupViews = services.map { (serviceFee) -> PriceDetailCell in
            let cell = PriceDetailCell.viewFromNib(with: BundleType.app)!
            cell.configureCell(serviceFee, currency: priceObj.currencyCode)
            return cell
        }

        // add
        groupViews.forEach { stackView.addArrangedSubview($0) }
    }
}
