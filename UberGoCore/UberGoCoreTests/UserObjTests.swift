//
//  UserObjTests.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/4/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import XCTest
import OAuthSwift
@testable import UberGoCore

class FakeUberCrendential {

    class func valid() -> OAuthSwiftCredential {
        let uber = OAuthSwiftCredential(consumerKey: "abc", consumerSecret: "secret")
        uber.oauthToken = "oauthToken"
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
}

class UserObjTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    fileprivate class func getFromDisk() -> UserObj? {

        guard let data = UserDefaults.standard.data(forKey: "currentUser") else { return nil }
        guard let userObj = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserObj else { return nil }

        return userObj
    }

    func testCreateUserWithCredentialUber() {

        // Given
        let uberCrendential = FakeUberCrendential.valid()

        // When
        let currentUser = UserObj.convertCurrentUser(with: uberCrendential)

        let savedUser = UserObjTests.getFromDisk()

        // Then
        XCTAssertEqual(currentUser, UserObj.currentUser, "Current User != UserObj.currentUser is difference")
        XCTAssertNotNil(savedUser, "Saved User is nil")
        XCTAssertEqual(UserObj.currentUser?.oauthToken, savedUser?.oauthToken, "Not same Access token")
    }

    func testAuthenticationStateWithValidToken() {

        // Given
        let uberCrendential = FakeUberCrendential.valid()
        let currentUser = UserObj.convertCurrentUser(with: uberCrendential)

        // Then
        XCTAssertEqual(currentUser.authenticateState, .authenticated, "Authentication State not work")
    }

    func testAuthenticationStateWithInvalidToken() {

        // Given
        let uberCrendential = FakeUberCrendential.invalid()
        let currentUser = UserObj.convertCurrentUser(with: uberCrendential)

        // Then
        XCTAssertEqual(currentUser.authenticateState, .unAuthenticated, "Authentication State not work")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
