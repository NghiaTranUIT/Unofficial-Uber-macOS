//
//  UberAPITests.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/6/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import XCTest
import CoreLocation
import RxSwift
@testable import UberGoCore

class UberAPITests: XCTestCase {

    let disposeBag = DisposeBag()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testUberProductsRequestAPIWorkSuccess() {

        // When
        let location = CLLocationCoordinate2D(latitude: 10.79901740, longitude: 106.75191281)
        let param = UberProductsRequestParam(location: location)
        let promise = expectation(description: "Uber Product API")
        let uberCrendential = FakeUberCrendential.valid()
        _ = UserObj.convertCurrentUser(with: uberCrendential)

        // Then
        UberProductsRequest(param).toObservable()
        .subscribe(onNext: { (productObjs) in
            promise.fulfill()
        }, onError: { error in
            XCTFail(error.localizedDescription)
        })
        .addDisposableTo(self.disposeBag)

        // Expect
        waitForExpectations(timeout: 10, handler: nil)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
