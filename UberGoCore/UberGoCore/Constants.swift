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

        static let BaseProductionURL = "https://api.uber.com"
        static let BaseSandboxURL = "https://sandbox-api.uber.com"

        static let LoginURL = "oauth/v2/authorize"
        static let UberProducts = "/v1.2/products"
        static let HomePersonalPlace = "/v1.2/places/home"
        static let WorkPseronalPlace = "/v1.2/places/work"
        static let RideEstimatePrice = "/v1.2/estimates/price"
        static let GetCurrentTrip = "/v1.2/requests/current"
        static let RequestEstimate = "/v1.2/requests/estimate"
        static let CreateTripRequest = "/v1.2/requests"
        static let GetPaymentMethod = "/v1.2/payment-methods"

        // Sandbox
        static let SandboxUpdateProduct = "/sandbox/products/:id"
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

        // MARK: - Uber Personal Place
        struct UberPersonalPlace {

            static let Address = "address"
        }

        // MARK: - Price
        struct Price {

            static let LocalizedDisplayName = "localized_display_name"
            static let Distance = "distance"
            static let DisplayName = "display_name"
            static let ProductId = "product_id"
            static let HighEstimate = "high_estimate"
            static let LowEstimate = "low_estimate"
            static let Duration = "duration"
            static let Estimate = "estimate"
            static let CurrencyCode = "currency_code"
        }

        // MARK: - Trip
        struct Trip {
            static let ProductId = "product_id"
            static let RequestId = "request_id"
            static let Status = "status"
            static let SurgeMultiplier = "surge_multiplier"
            static let Shared = "shared"
            static let Driver = "driver"
            static let Vehicle = "vehicle"
            static let Location = "location"
            static let Pickup = "pickup"
            static let Destination = "destination"
            static let Waypoints = "waypoints"
            static let Riders = "riders"
        }

        // MARK: - Waypoint
        struct Waypoint {

            static let RiderId = "rider_id"
            static let Latitude = "latitude"
            static let Longitude = "longitude"
            static let `Type` = "type"
        }

        // MARK: - Rider
        struct Rider {

            static let RiderId = "rider_id"
            static let FirstName = "first_name"
            static let Me = "me"
        }

        // MARK: - Driver
        struct Driver {

            static let PhoneNumber = "phone_number"
            static let SmsNumber = "sms_number"
            static let Rating = "rating"
            static let PictureUrl = "picture_url"
            static let Name = "name"
        }

        // MARK: - Vehicle
        struct Vehicle {

            static let Make = "make"
            static let Model = "model"
            static let LicensePlate = "license_plate"
            static let PictureUrl = "picture_url"
        }

        // MARK: - Payment
        struct Payment {

            static let PaymentMethods = "payment_methods"
            static let LastUsed = "last_used"
        }

        struct PaymentAccount {

            static let PaymentMethodId = "payment_method_id"
            static let `Type` = "type"
            static let Description = "description"
        }
    }
}
