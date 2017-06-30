//
//  AuthToken.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/30/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation
import OAuthSwift

public class AuthToken: NSCoding {

    // MARK: - Token
    public var token: String
    public var refreshToken: String
    public var tokenSecret: String
    public var tokenExpires: Date?

    // MARK: - Init
    init(token: String, refreshToken: String, tokenSecret: String, tokenExpires: Date?) {
        self.token = token
        self.refreshToken = refreshToken
        self.tokenSecret = tokenSecret
        self.tokenExpires = tokenExpires
    }

    public init(credential: OAuthSwiftCredential) {
        self.token = credential.oauthToken
        self.refreshToken = credential.oauthRefreshToken
        self.tokenSecret = credential.oauthTokenSecret
        self.tokenExpires = credential.oauthTokenExpiresAt
    }

    // MARK: - Set
    public func setAuthenticationHeader(request: inout URLRequest) {
        let tokenStr = "Bearer " + token
        request.setValue(tokenStr, forHTTPHeaderField: "Authorization")
    }

    // MARK: - NSCoding
    public required init?(coder aDecoder: NSCoder) {
        self.token = aDecoder.decodeObject(forKey: Constants.Object.Auth.OauthToken) as! String
        self.refreshToken = aDecoder.decodeObject(forKey: Constants.Object.Auth.OauthTokenSecret) as! String
        self.tokenSecret = aDecoder.decodeObject(forKey: Constants.Object.Auth.OauthTokenSecret) as! String
        self.tokenExpires = aDecoder.decodeObject(forKey: Constants.Object.Auth.OauthTokenExpiresAt) as? Date
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.token, forKey: Constants.Object.Auth.OauthToken)
        aCoder.encode(self.refreshToken, forKey: Constants.Object.Auth.OauthRefreshToken)
        aCoder.encode(self.tokenSecret, forKey: Constants.Object.Auth.OauthTokenSecret)
        aCoder.encode(self.tokenExpires, forKey: Constants.Object.Auth.OauthTokenExpiresAt)
    }
}
