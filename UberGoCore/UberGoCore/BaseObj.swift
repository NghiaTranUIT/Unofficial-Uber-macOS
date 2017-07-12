//
//  BaseObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/2/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa
import Unbox
import RxSwift

open class BaseObj: NSObject, Unboxable, NSCoding {

    // MARK: - Variable
    public var objectId = UUID.shortUUID()
    public var createdAt = Date()
    public var updatedAt = Date()
    public let disposeBag = DisposeBag()

    // MARK: - Init
    public override init() {
        super.init()
    }

    public required init(unboxer: Unboxer) throws {

    }

    public required init?(coder aDecoder: NSCoder) {
        objectId = aDecoder.decodeObject(forKey: Constants.Object.ObjectId) as! String
        createdAt = aDecoder.decodeObject(forKey: Constants.Object.CreatedAt) as! Date
        updatedAt = aDecoder.decodeObject(forKey: Constants.Object.UpdatedAt) as! Date
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(objectId)
        aCoder.encode(createdAt)
        aCoder.encode(updatedAt)
    }

}

