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
                let paymentAccountObjs = paymentObj.paymentAccountObjs

                // Check lastUsed must match to any paymentMethods
                if let lastUsed = paymentObj.lastUsed {
                    let matched = paymentAccountObjs.first(where: { (obj) -> Bool in
                        if obj.paymentMethodId == lastUsed {
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
                    if lastPaymentObj.paymentMethodId != lastUsed {
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

    func testRequestProductDetailObserver() {

        let promise = expectation(description: "testRequestProductDetailObserver")
        FakeUberCrendential.makeCurrentUser()
        let location = LocationHelper.originLocation

        // Then
        UberService().availableProductsObserver(at: location)
            .subscribe(onNext: { [unowned self] products in

                guard let firstObj = products.first else {
                    XCTFail("No Product available")
                    return
                }

                // Then
                UberService().requestPriceDetail(firstObj.productId)
                    .subscribe(onNext: { product in
                        if product.priceDetailVariable.value == nil {
                            XCTFail("productDetail is nil")
                        }
                        promise.fulfill()
                    }, onError: { error in
                        XCTFail(error.localizedDescription)
                    })
                    .addDisposableTo(self.disposeBag)

            }, onError: { error in
                XCTFail(error.localizedDescription)
            })
            .addDisposableTo(self.disposeBag)

        // Expect
        waitForExpectations(timeout: 10, handler: nil)
    }

}
