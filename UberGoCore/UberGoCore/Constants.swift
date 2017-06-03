//
//  Constants.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/1/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa

struct Constants {

    // MARK: - Uber
    struct UberAPI {

        static let BaseURL = "https://login.uber.com"
        static let LoginURL = "oauth/v2/authorize"
    }

    // MARK: - Object
    struct Object {

        static let ObjectId = "objectID"
        static let CreatedAt = "createdAt"
        static let UpdatedAt = "updatedAt"

        // MARK: - User
        struct User {
            static let Name = "name"
        }
    }
}
