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
        static let SecretID = "wf8GyZoiHgcXq2T7Z3Kp9cui3n9HNq41nKYH__qU"
        static let AuthorizeUrl = "https://login.uber.com/oauth/v2/authorize"
        static let AccessTokenUrl = "https://login.uber.com/oauth/v2/token"
        static let ResponseType = "code"
        static let CallBackUrl = "oauth-uber://oauth-callback/uber"
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
        static let RideEstimateTime = "/v1.2/estimates/time"
        static let GetCurrentTrip = "/v1.2/requests/current"
        static let RequestEstimate = "/v1.2/requests/estimate"
        static let CreateTripRequest = "/v1.2/requests"
        static let GetPaymentMethod = "/v1.2/payment-methods"
        static let ProductDetail = "/v1.2/products/:id"

        // Sandbox
        static let SandboxUpdateProduct = "/v1.2/sandbox/products/:id"
        static let SandboxUpdateStatusTrip = "/v1.2/sandbox/requests/:id"
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
            static let Auth = "auth"
        }

        // MARK: - Auth
        struct Auth {
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
            static let PriceDetails = "price_details"
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
            static let SurgeMultiplier = "surge_multiplier"
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
            static let type = "type"
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

        // MARK: - PaymentAccount
        struct PaymentAccount {

            static let PaymentMethodId = "payment_method_id"
            static let type = "type"
            static let Description = "description"
        }

        // MARK: - TimeEstimate
        struct TimeEstimate {

            static let LocalizedDisplayName = "localized_display_name"
            static let Estimate = "estimate"
            static let DisplayName = "display_name"
            static let ProductId = "product_id"
        }

        // MARK: - Price Detail
        struct PriceDetail {

            static let ServiceFees = "service_fees"
            static let CostPerMinute = "cost_per_minute"
            static let DistanceUnit = "distance_unit"
            static let Minimum = "minimum"
            static let CostPerDistance = "cost_per_distance"
            static let Base = "base"
            static let CancellationFee = "cancellation_fee"
            static let CurrencyCode = "currency_code"
        }

        // MARK: - Service Fee
        struct ServiceFee {

            static let Fee = "fee"
            static let Name = "name"
        }
    }
}
