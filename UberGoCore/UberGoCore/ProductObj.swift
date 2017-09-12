//
//  ProductObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/5/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import RxSwift
import Unbox

public class ProductObj: Unboxable {

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
    fileprivate let disposeBag = DisposeBag()

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
        upfrontFareEnabled = try unboxer.unbox(key: Constants.Object.Product.UpfrontFareEnabled)
        capacity = try unboxer.unbox(key: Constants.Object.Product.Capacity)
        productId = try unboxer.unbox(key: Constants.Object.Product.ProductId)
        image = try unboxer.unbox(key: Constants.Object.Product.Image)
        cashEnabled = try unboxer.unbox(key: Constants.Object.Product.CashEnabled)
        shared = try unboxer.unbox(key: Constants.Object.Product.Shared)
        shortDescription = try unboxer.unbox(key: Constants.Object.Product.ShortDescription)
        displayName = try unboxer.unbox(key: Constants.Object.Product.DisplayName)
        productGroup = try unboxer.unbox(key: Constants.Object.Product.ProductGroup)
        descr = try unboxer.unbox(key: Constants.Object.Product.Description)
        priceDetail = unboxer.unbox(key: Constants.Object.Product.PriceDetails)
    }

    public init(upfrontFareEnabled: Bool,
                capacity: Int,
                productId: String,
                image: String,
                cashEnabled: Bool,
                shared: Bool,
                shortDescription: String,
                displayName: String,
                productGroup: String,
                descr: String) {
        self.upfrontFareEnabled = upfrontFareEnabled
        self.capacity = capacity
        self.productId = productId
        self.image = image
        self.cashEnabled = cashEnabled
        self.shared = shared
        self.shortDescription = shortDescription
        self.displayName = displayName
        self.productGroup = productGroup
        self.descr = descr
    }

    // Only for testing purpose
    public convenience init(productId: String) {
        self.init(upfrontFareEnabled: true,
                  capacity: 0,
                  productId: productId,
                  image: "",
                  cashEnabled: true,
                  shared: false,
                  shortDescription: "",
                  displayName: "",
                  productGroup: "",
                  descr: "")
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

public class GroupProductObj {

    // MARK: - Variable
    public var productGroup: String
    public var productObjs: [ProductObj] = []

    // MARK: - Init
    public init(productGroup: String, productObjs: [ProductObj]) {
        self.productGroup = productGroup
        self.productObjs = productObjs

        // UberShip
        // API return "" // Empty string
        // Workaround
        if productGroup == "" {
            guard let first = productObjs.first else { return }
            self.productGroup = first.displayName
        }
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
