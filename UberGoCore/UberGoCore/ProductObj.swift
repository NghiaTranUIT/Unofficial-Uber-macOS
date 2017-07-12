//
//  ProductObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/5/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Unbox
import RxSwift

open class ProductObj: BaseObj {

    // MARK: - Variable
    public var upfrontFareEnabled: Bool
    public var capacity: Int
    public var productId: String
    public var image: String
    public var cashEnabled: Bool
    public var shared: Bool
    public var shortDescription: String
    public var displayName: String
    public var productGroup: String
    public var descr: String

    // Pretty
    public var prettyCapacity: String {
        return capacity == 1 ? "1" : "1 - \(capacity)"
    }

    // Price from Uber
    public var estimatePrice: PriceObj?
    public var estimateTime: TimeEstimateObj?

    // Product Detail
    public var priceDetail: PriceDetailObj?
    public lazy var priceDetailVariable: Variable<PriceDetailObj?> = self.initLazyPriceDetail()

    // MARK: - Init
    public required init(unboxer: Unboxer) throws {
        self.upfrontFareEnabled = try unboxer.unbox(key: Constants.Object.Product.UpfrontFareEnabled)
        self.capacity = try unboxer.unbox(key: Constants.Object.Product.Capacity)
        self.productId = try unboxer.unbox(key: Constants.Object.Product.ProductId)
        self.image = try unboxer.unbox(key: Constants.Object.Product.Image)
        self.cashEnabled = try unboxer.unbox(key: Constants.Object.Product.CashEnabled)
        self.shared = try unboxer.unbox(key: Constants.Object.Product.Shared)
        self.shortDescription = try unboxer.unbox(key: Constants.Object.Product.ShortDescription)
        self.displayName = try unboxer.unbox(key: Constants.Object.Product.DisplayName)
        self.productGroup = try unboxer.unbox(key: Constants.Object.Product.ProductGroup)
        self.descr = try unboxer.unbox(key: Constants.Object.Product.Description)
        self.priceDetail = unboxer.unbox(key: Constants.Object.Product.PriceDetails)
        try super.init(unboxer: unboxer)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    fileprivate func initLazyPriceDetail() -> Variable<PriceDetailObj?> {
        return Variable<PriceDetailObj?>(priceDetail)
    }

    // MARK: - Public
    public func updatePriceDetail() {
        UberService().requestPriceDetail(productId)
            .map { $0.priceDetail }
            .filterNil()
            .bind(to: priceDetailVariable)
            .addDisposableTo(disposeBag)
    }
}

open class GroupProductObj: BaseObj {

    // MARK: - Variable
    public var productGroup: String
    public var productObjs: [ProductObj] = []

    // MARK: - Init
    public init(productGroup: String, productObjs: [ProductObj]) {
        self.productGroup = productGroup
        self.productObjs = productObjs
        super.init()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public required init(unboxer: Unboxer) throws {

    }

    // MARK: - Public
    public class func mapProductGroups(from productObjs: [ProductObj]) -> [GroupProductObj] {

        // Get unique group name
        let groupNames = productObjs.map { $0.productGroup }
                                    .uniqueElements

        // Map
        return groupNames.map({ name -> GroupProductObj in

            // Get all product with same GroupName
            let subProducts = productObjs.filter({ $0.productGroup == name })

            // Map to Group
            return GroupProductObj(productGroup: name, productObjs: subProducts)
        })
    }
}
