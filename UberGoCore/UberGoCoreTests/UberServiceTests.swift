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

class UberServiceTests: XCTestCase {

    let disposeBag = DisposeBag()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()

        FakeUberCrendential.resetData()
    }

    func testUberProductsRequestAPIWorkSuccess() {

        // When
        let location = LocationHelper.originLocation
        let param = UberProductsRequestParam(location: location)
        let promise = expectation(description: "testUberProductsRequestAPIWorkSuccess")
        FakeUberCrendential.makeCurrentUser()

        // Then
        UberProductsRequest(param).toObservable()
        .subscribe(onNext: { _ in
            promise.fulfill()
        }, onError: { error in
            XCTFail(error.localizedDescription)
        })
        .addDisposableTo(self.disposeBag)

        // Expect
        waitForExpectations(timeout: 10, handler: nil)
    }

    func testUberPersonalRequestAPIWorkSuccess() {

        // When
        let param = UberPersonalPlaceRequestParam(placeType: .home)
        let promise = expectation(description: "testUberPersonalRequestAPIWorkSuccess")
        FakeUberCrendential.makeCurrentUser()

        // Then
        UberPersonalPlaceRequest(param).toObservable()
            .subscribe(onNext: { _ in
                promise.fulfill()
            }, onError: { error in
                XCTFail(error.localizedDescription)
            })
            .addDisposableTo(self.disposeBag)

        // Expect
        waitForExpectations(timeout: 10, handler: nil)
    }

    func testGetHomeWorkPersonalPlaceWorkSuceess() {

        let promise = expectation(description: "testGetHomeWorkPersonalPlaceWorkSuceess")
        FakeUberCrendential.makeCurrentUser()

        // Then 
        UberService().personalPlaceObserver()
            .subscribe(onNext: { uberPlaceObjs in

                // Check if addrees != nil
                for obj in uberPlaceObjs {
                    if obj.address == nil {
                        XCTFail("Uber Personal Place's adress is invalid")
                    }
                }
                promise.fulfill()
            }, onError: { error in
                XCTFail(error.localizedDescription)
            })
            .addDisposableTo(self.disposeBag)

        // Expect
        waitForExpectations(timeout: 10, handler: nil)
    }

    func testRideEstimatePriceRequestWorkSuceess() {

        let promise = expectation(description: "testRideEstimatePriceRequestWorkSuceess")
        FakeUberCrendential.makeCurrentUser()
        let from = LocationHelper.originLocation
        let to = LocationHelper.destinationLocation

        // Then
        UberService().rideEstimatePrice(from: from, to: to)
            .subscribe(onNext: { priceObjs in

                // Check if product_id != nil
                for obj in priceObjs {
                    if obj.productId == nil {
                        XCTFail("Uber Personal Place's adress is invalid")
                    }
                }

                promise.fulfill()
            }, onError: { error in
                XCTFail(error.localizedDescription)
            })
            .addDisposableTo(self.disposeBag)

        // Expect
        waitForExpectations(timeout: 10, handler: nil)
    }
}
