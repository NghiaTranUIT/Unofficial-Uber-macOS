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

class UserObjTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        super.tearDown()

        // Remove

    }

    func testCreateUserWithCredentialUber() {

        // Given
        let uberCrendential = FakeUberCrendential.valid()

        // When
        let currentUser = UserObj.convertCurrentUser(with: uberCrendential)
        let savedUser = FakeUberCrendential.getFromDisk()

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
