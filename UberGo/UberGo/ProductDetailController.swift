//
//  ProductDetailController.swift
//  UberGo
//
//  Created by Nghia Tran on 7/2/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import UberGoCore

protocol ProductDetailControllerDelegate: class {
    func productDetailControllerShouldDimiss()
}

class ProductDetailController: NSViewController {

    // MARK: - OUTLET
    @IBOutlet fileprivate weak var productImageView: NSImageView!
    @IBOutlet fileprivate weak var productNameLbl: NSTextField!
    @IBOutlet fileprivate weak var descriptionLbl: NSTextField!
    @IBOutlet fileprivate weak var descriptionLblTop: NSLayoutConstraint!
    @IBOutlet fileprivate weak var fareLbl: NSTextField!
    @IBOutlet fileprivate weak var capacityLbl: NSTextField!
    @IBOutlet fileprivate weak var timeArrvivalLbl: NSTextField!
    @IBOutlet fileprivate weak var timeLbl: NSTextField!
    @IBOutlet fileprivate weak var dividerLineTime: NSBox!

    // MARK: - Variable
    public weak var delegate: ProductDetailControllerDelegate?
    fileprivate var productObj: ProductObj!

    // MARK: - View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        initCommon()
        setupLayout()
        setupData()
    }

    public func configureController(with productObj: ProductObj) {
        self.productObj = productObj
    }

    @IBAction func doneBtnOnTap(_ sender: Any) {
        delegate?.productDetailControllerShouldDimiss()
    }

    @IBAction func breakdownBtnOnTap(_ sender: Any) {

    }
}

// MARK: - Private
extension ProductDetailController {

    fileprivate func initCommon() {
    }

    fileprivate func setupLayout() {

        var isHidden = false
        var topConstant: CGFloat = 36.0

        // Hide Time estimate
        if productObj.estimateTime == nil {
            isHidden = true
            topConstant = 16.0
        }

        timeLbl.isHidden = isHidden
        timeArrvivalLbl.isHidden = isHidden
        dividerLineTime.isHidden = isHidden

        // Update layout
        descriptionLblTop.constant = topConstant
        view.layoutSubtreeIfNeeded()
    }

    fileprivate func setupData() {

        // Image
        productImageView.image = NSImage(imageLiteralResourceName: "uber_car_selected")

        // Name
        productNameLbl.stringValue = productObj.displayName ?? ""

        // Desc
        descriptionLbl.stringValue = productObj.descr ?? ""

        // Capcity
        capacityLbl.stringValue = productObj.prettyCapacity

        // Arrive
        if let estimateTime = productObj.estimateTime {
            timeArrvivalLbl.stringValue = "\(estimateTime.prettyEstimateTime) mins"
        }

        // Fare
        if let estimatePrice = productObj.estimatePrice {
            fareLbl.stringValue = estimatePrice.estimate ?? "xxx"
        }
    }
}
