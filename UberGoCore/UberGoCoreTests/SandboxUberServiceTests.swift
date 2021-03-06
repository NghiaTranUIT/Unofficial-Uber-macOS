//
//  SandboxUberServiceTests.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/20/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import XCTest
import CoreLocation
import RxSwift
import Alamofire
import Unbox
@testable import UberGoCore

class SandboxUberServiceTests: XCTestCase {

    let disposeBag = DisposeBag()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        FakeUberCrendential.resetData()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()

        FakeUberCrendential.resetData()
    }

    func testModifySandboxProductObserver() {

        let promise = expectation(description: "testModifySandboxProductObserver")
        FakeUberCrendential.makeCurrentUser()

        let productObj = ProductObj(productId: "0b6b2de2-a6f3-4fa7-8385-414312f042ce")

        // Then
        SandboxUberService().modifySandboxProductObserver(productObj: productObj, surgeRate: 2.4, available: true)
            .subscribe(onNext: { productObjs in
                promise.fulfill()
            }, onError: { error in
                XCTFail(error.localizedDescription)
            })
            .addDisposableTo(self.disposeBag)

        // Expect
        waitForExpectations(timeout: 10, handler: nil)
    }

}
