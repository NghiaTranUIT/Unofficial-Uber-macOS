//
//  ProductObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/5/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa
import ObjectMapper

open class ProductObj: BaseObj {

    // MARK: - Variable
    public var upfrontFareEnabled: Bool?
    public var capacity: Int?
    public var productId: String?
    public var image: String?
    public var cashEnabled: Bool?
    public var shared: Bool?
    public var shortDescription: String?
    public var displayName: String?
    public var productGroup: String?
    public var descr: String?

    // Price from Uber
    public var estimatePrice: PriceObj?
    public var estimateTime: TimeEstimateObj?

    override public func mapping(map: Map) {
        super.mapping(map: map)

        self.upfrontFareEnabled <- map[Constants.Object.Product.UpfrontFareEnabled]
        self.capacity <- map[Constants.Object.Product.Capacity]
        self.productId <- map[Constants.Object.Product.ProductId]
        self.image <- map[Constants.Object.Product.Image]
        self.cashEnabled <- map[Constants.Object.Product.CashEnabled]
        self.shared <- map[Constants.Object.Product.Shared]
        self.shortDescription <- map[Constants.Object.Product.ShortDescription]
        self.displayName <- map[Constants.Object.Product.DisplayName]
        self.productGroup <- map[Constants.Object.Product.ProductGroup]
        self.descr <- map[Constants.Object.Product.Description]
    }
}

open class GroupProductObj: BaseObj {

    // MARK: - Variable
    public var productGroup: String!
    public var productObjs: [ProductObj] = []

    // MARK: - Init
    public convenience init(productGroup: String, productObjs: [ProductObj]) {
        self.init()
        self.productGroup = productGroup
        self.productObjs = productObjs
    }

    // MARK: - Public
    public class func mapProductGroups(from productObjs: [ProductObj]) -> [GroupProductObj] {

        // Get unique group name
        let groupNames = productObjs.map { $0.productGroup! }
                                    .uniqueElements

        // Map
        return groupNames.map({ name -> GroupProductObj in

            // Get all product with same GroupName
            let subProducts = productObjs.filter({ $0.productGroup! == name })

            // Map to Group
            return GroupProductObj(productGroup: name, productObjs: subProducts)
        })
    }
}
