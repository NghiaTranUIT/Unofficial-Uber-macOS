//
//  UserObjHelper.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/6/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation
import OAuthSwift
@testable import UberGoCore

class FakeUberCrendential {

    class func valid() -> OAuthSwiftCredential {
        let uber = OAuthSwiftCredential(consumerKey: "abc", consumerSecret: "secret")
        uber.oauthToken = "KA.eyJ2ZXJzaW9uIjoyLCJpZCI6IlBjR29JWmNWVEk2RUFUbGRnTTl0UXc9PSIsImV4cGlyZXNfYXQiOjE1MTIwMDk5ODIsInBpcGVsaW5lX2tleV9pZCI6Ik1RPT0iLCJwaXBlbGluZV9pZCI6MX0.j4_P4CxiwQNCjV81Ya4PtpJEdCJN9Ayayo7ih6uTVSo"
        uber.oauthTokenSecret = "oauthTokenSecret"
        uber.oauthTokenExpiresAt = Date()
        uber.oauthRefreshToken = "oauthRefreshToken"
        return uber
    }

    class func invalid() -> OAuthSwiftCredential {
        let uber = OAuthSwiftCredential(consumerKey: "abc", consumerSecret: "secret")
        uber.oauthToken = ""
        uber.oauthTokenSecret = "oauthTokenSecret"
        uber.oauthTokenExpiresAt = Date()
        uber.oauthRefreshToken = "oauthRefreshToken"
        return uber
    }

    class func getFromDisk() -> UserObj? {

        guard let data = UserDefaults.standard.data(forKey: "Uber.CurrentUser") else { return nil }
        guard let userObj = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserObj else { return nil }

        return userObj
    }

    class func resetData() {
        UberAuth.share.logout()
    }

    class func makeCurrentUser() {
        let uberCrendential = FakeUberCrendential.valid()
        UberAuth.share.convertToCurrentUser(uberCrendential)
    }
}
