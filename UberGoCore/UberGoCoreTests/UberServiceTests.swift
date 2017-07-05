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
import Alamofire
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

    func testAvailableProductsObserver() {

        // When
        let location = LocationHelper.originLocation
        let promise = expectation(description: "testAvailableProductsObserver")
        FakeUberCrendential.makeCurrentUser()

        // Then
        UberService().availableProductsObserver(at: location)
        .subscribe(onNext: { products in
            if products.count == 0 {
                XCTFail("None available product at testAvailableProductsObserver")
            }
            for obj in products {
                if obj.productId == nil {
                    XCTFail("Uber Product's productID is invalid")
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

    func testPersonalPlaceObserver() {

        let promise = expectation(description: "testPersonalPlaceObserver")
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

    func testEstimatePriceObserver() {

        let promise = expectation(description: "testEstimatePriceObserver")
        FakeUberCrendential.makeCurrentUser()
        let from = LocationHelper.originLocation
        let to = LocationHelper.destinationLocation

        // Then
        UberService().estimatePriceObserver(from: from, to: to)
            .subscribe(onNext: { priceObjs in

                // Check if product_id != nil
                for obj in priceObjs {
                    if obj.productId == nil {
                        XCTFail("Uber Estimate Price is invalid")
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

    func testEstimateTimeObserver() {

        let promise = expectation(description: "testEstimateTimeObserver")
        FakeUberCrendential.makeCurrentUser()
        let from = LocationHelper.originLocation

        // Then
        UberService().estimateTimeObserver(from: from)
            .subscribe(onNext: { timeObj in

                // Check if product_id != nil
                for obj in timeObj {
                    if obj.productId == nil {
                        XCTFail("Uber Time Estimate is invalid")
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

    func testProductsWithEstimatePriceObserver() {

        let promise = expectation(description: "testProductsWithEstimatePriceObserver")
        FakeUberCrendential.makeCurrentUser()
        let from = LocationHelper.originLocation
        let to = LocationHelper.destinationLocation

        // Then
        UberService().productsWithEstimatePriceObserver(from: from, to: to)
            .subscribe(onNext: { productObjs in

                // Check if product_id != nil
                for obj in productObjs {
                    if obj.productId == nil {
                        XCTFail("Product's productID is invalid")
                    }
                }

                // Check if there is estimatePrice = nil
                for obj in productObjs {
                    if obj.estimatePrice == nil {
                        XCTFail("Product's estimatePrice is invalid")
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

    func testPaymentMethodObserver() {

        let promise = expectation(description: "testPaymentMethodObserver")
        FakeUberCrendential.makeCurrentUser()

        // Then
        UberService().paymentMethodObserver()
            .subscribe(onNext: { paymentObj in

                // Check if product_id != nil
                guard let paymentAccountObjs = paymentObj.paymentAccountObjs else {
                    XCTFail("No payment accounts")
                    return
                }

                // Check each
                for obj in paymentAccountObjs {
                    if obj.paymentMethodId == nil {
                        XCTFail("Payment account ID is invalid")
                    }
                }

                // Check lastUsed must match to any paymentMethods
                if let lastUsed = paymentObj.lastUsed {
                    let matched = paymentAccountObjs.first(where: { (obj) -> Bool in
                        guard let ID = obj.paymentMethodId else {
                            return false
                        }
                        if ID == lastUsed {
                            return true
                        }
                        return false
                    })
                    if matched == nil {
                        XCTFail("There is no LastUsed is invalid")
                    }
                }

                // Last Used Account must have same ID with lastUsed
                if let lastPaymentObj = paymentObj.lastUsedPaymentAccount,
                    let lastUsed = paymentObj.lastUsed {
                    if lastPaymentObj.paymentMethodId! != lastUsed {
                        XCTFail("LastUsed != LastUsedAccount")
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
