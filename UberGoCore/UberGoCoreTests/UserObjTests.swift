//
//  UserObjTests.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/4/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import XCTest
import RxSwift
import OAuthSwift
@testable import UberGoCore

class UserObjTests: XCTestCase {

    fileprivate let disposeBag = DisposeBag()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        super.tearDown()

        // Remove
        FakeUberCrendential.resetData()
    }

    func testCreateUserWithCredentialUber() {

        // Given
        let uberCrendential = FakeUberCrendential.valid()

        // When
        UberAuth.share.convertToCurrentUser(uberCrendential)
        let savedUser = FakeUberCrendential.getFromDisk()

        // Then
        XCTAssertNotNil(savedUser, "Saved User is nil")
        XCTAssertEqual(UberAuth.share.currentUser?.authToken.token, savedUser?.authToken.token, "Not same Access token")
    }

    func testAuthenticationStateWithValidToken() {

        // Given
        let uberCrendential = FakeUberCrendential.valid()
        UberAuth.share.convertToCurrentUser(uberCrendential)

        // Then
        XCTAssertNotNil(UberAuth.share.currentUser, "Current User is nil")
    }

    func testLogOut() {

        // Create
        FakeUberCrendential.makeCurrentUser()
        XCTAssertNotNil(FakeUberCrendential.getFromDisk())

        // Logout
        UberAuth.share.logout()

        // Nil
        XCTAssertNil(FakeUberCrendential.getFromDisk())
    }
}
