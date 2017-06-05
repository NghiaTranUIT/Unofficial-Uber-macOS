//
//  Constants.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/1/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa

struct Constants {

    // MARK: - UberApp
    struct UberApp {

        static let ClientID = "fwjlEcQ945pan5s4rYLPzaVhcrbuFPHB"
        static let SecretID = "nyViKGlehMn89Wdu0UFJN_flPKi601T4_CHnude8"
        static let AuthorizeUrl = "https://login.uber.com/oauth/v2/authorize"
        static let AccessTokenUrl = "https://login.uber.com/oauth/v2/token"
        static let ResponseType = "code"
        static let CallBackUrl = "oauth-swift://oauth-callback/uber"
    }

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
            static let OauthToken = "oauthToken"
            static let OauthRefreshToken = "oauthRefreshToken"
            static let OauthTokenSecret = "oauthTokenSecret"
            static let OauthTokenExpiresAt = "oauthTokenExpiresAt"
        }
    }
}
