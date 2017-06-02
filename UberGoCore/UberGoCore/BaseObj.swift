//
//  BaseObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/2/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa
import ObjectMapper

class BaseObj: NSObject, Mappable {
    
    // MARK: - Variable
    public var objectId: String?
    public var createdAt: Date?
    public var updatedAt: Date?
    
    // MARK: - Init
    public required init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        self.objectId <- map[Constants.Object.objectId]
        self.createdAt <- map[Constants.Object.createdAt]
        self.updatedAt <- map[Constants.Object.updatedAt]
    }
}
