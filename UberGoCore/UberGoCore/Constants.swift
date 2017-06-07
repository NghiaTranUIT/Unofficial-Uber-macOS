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

        static let BaseURL = "https://api.uber.com"
        static let LoginURL = "oauth/v2/authorize"
        static let UberProducts = "/v1.2/products"
        static let HomePersonalPlace = "/v1.2/products/home"
        static let WorkPseronalPlace = "/v1.2/products/work"
    }

    // MARK: - Google App
    struct GoogleApp {
        static let Key = "AIzaSyD_WRNqPyKqD9UoVgATUisFbXFF19gcfDU"
    }

    // MARK: - Google
    struct GoogleAPI {

        static let BaseURL = "https://maps.googleapis.com/maps/api"
        static let PlaceSearchURL = "/place/nearbysearch/json"
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

        // MARK: - Product
        struct Product {

            static let UpfrontFareEnabled = "upfront_fare_enabled"
            static let Capacity = "capacity"
            static let ProductId = "product_id"
            static let Image = "image"
            static let CashEnabled = "cash_enabled"
            static let Shared = "shared"
            static let ShortDescription = "short_description"
            static let DisplayName = "display_name"
            static let ProductGroup = "product_group"
            static let Description = "description"
        }
    }
}
