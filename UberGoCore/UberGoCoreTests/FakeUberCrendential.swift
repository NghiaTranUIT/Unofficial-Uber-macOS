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
        uber.oauthToken = "KA.eyJ2ZXJzaW9uIjoyLCJpZCI6Imc4bEFRSWxMUk5LNGF3WXRYVXFsQVE9PSIsImV4cGlyZXNfYXQiOjE0OTkxNDUyNDIsInBpcGVsaW5lX2tleV9pZCI6Ik1RPT0iLCJwaXBlbGluZV9pZCI6MX0.ONbzHyX58JAYgpzlH3XKcADH2ukVUsPhRNNRLll0NM0"
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
        UserDefaults.standard.removeObject(forKey: "Uber.CurrentUser")
        UserDefaults.standard.synchronize()
    }

    class func makeCurrentUser() {
        let uberCrendential = FakeUberCrendential.valid()
        UberAuth.share.convertToCurrentUser(uberCrendential)
    }
}
