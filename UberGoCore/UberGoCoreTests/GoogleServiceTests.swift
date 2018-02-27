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
import Alamofire
@testable import UberGoCore

class GoogleServiceTests: XCTestCase {

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

    func testSearchPlaceAPIWorkSuccess() {

        // When
        let location = CLLocationCoordinate2D(latitude: 10.79901740, longitude: 106.75191281)
        let promise = expectation(description: "Place Search API has results")

        // Then
        GoogleMapService().searchPlaces(with: "rmit", currentLocation: location)
        .subscribe(onNext: { placeObjs in
            print(placeObjs)
            promise.fulfill()
        }, onError: { error in
            XCTFail(error.localizedDescription)
        })
        .disposed(by: self.disposeBag)

        // Expect
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testNearestPlaceAPIWorkSuccess() {

        // When
        let location = CLLocationCoordinate2D(latitude: 10.79901740, longitude: 106.75191281)
        let param = PlaceSearchRequestParam(location: location)
        let promise = expectation(description: "Place Search API has results")

        // Then
        PlaceSearchRequest(param)
            .toObservable()
            .subscribe(onNext: { placeObjs in
                print(placeObjs)
                promise.fulfill()
            }, onError: { error in
                XCTFail(error.localizedDescription)
            })
            .disposed(by: self.disposeBag)

        // Expect
        waitForExpectations(timeout: 5, handler: nil)
    }
}
