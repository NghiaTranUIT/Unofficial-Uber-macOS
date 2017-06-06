//
//  GoogleAPITests.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/6/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import XCTest
import CoreLocation
import RxSwift
@testable import UberGoCore

class GoogleAPITests: XCTestCase {

    let disposeBag = DisposeBag()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSearchPlaceAPIWorkSuccess() {
        let location = CLLocationCoordinate2D(latitude: 10.79901740, longitude: 106.75191281)
        let param = PlaceSearchRequestParam(keyword: "rmit", location: location)

        let promise = expectation(description: "Place Search API has results")

        PlaceSearchRequest(param).toObservable()
        .subscribe(onNext: { placeObjs in
            print(placeObjs)
            promise.fulfill()
        }, onError: { error in
            XCTFail(error.localizedDescription)
        }).addDisposableTo(self.disposeBag)

        // Expect
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
