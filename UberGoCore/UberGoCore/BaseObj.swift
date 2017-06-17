//
//  BaseObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/2/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa
import ObjectMapper

open class BaseObj: NSObject, Mappable, NSCoding {

    // MARK: - Variable
    public var objectId: String?
    public var createdAt: Date?
    public var updatedAt: Date?

    // MARK: - Init
    public override init() {
        super.init()

        self.objectId = UUID.shortUUID()
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    public required init?(map: Map) {
    
    }

    public func mapping(map: Map) {
        self.objectId <- map[Constants.Object.ObjectId]
        self.createdAt <- map[Constants.Object.CreatedAt]
        self.updatedAt <- map[Constants.Object.UpdatedAt]
    }

    public required init?(coder aDecoder: NSCoder) {
        self.objectId = aDecoder.decodeObject(forKey: Constants.Object.ObjectId) as? String
        self.createdAt = aDecoder.decodeObject(forKey: Constants.Object.CreatedAt) as? Date
        self.updatedAt = aDecoder.decodeObject(forKey: Constants.Object.UpdatedAt) as? Date
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.objectId)
        aCoder.encode(self.createdAt)
        aCoder.encode(self.updatedAt)
    }
}
