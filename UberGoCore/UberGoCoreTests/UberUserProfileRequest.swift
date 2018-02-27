//
//  UberUserProfileRequest.swift
//  UberGoCoreTests
//
//  Created by Nghia Tran on 9/17/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import XCTest
import RxSwift
import Alamofire
@testable import UberGoCore

class UberUserProfileRequest: XCTestCase {

    fileprivate let disposeBag = DisposeBag()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()

        FakeUberCrendential.resetData()
    }

    func testCurrentUserProfile() {

        // When
        let promise = expectation(description: "testCurrentUserProfile")
        FakeUberCrendential.makeCurrentUser()

        // Then
        ProfileRequest().toObservable()
            .subscribe(onNext: { (user) in
                promise.fulfill()
            }, onError: { error in
                XCTFail(error.localizedDescription)
            })
        .disposed(by: disposeBag)

        // Expect
        waitForExpectations(timeout: 10, handler: nil)
    }
}
