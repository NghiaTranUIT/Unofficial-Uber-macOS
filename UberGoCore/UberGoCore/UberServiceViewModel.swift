//
//  UberServiceViewModel.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/20/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import CoreLocation
import Foundation
import RxCocoa
import RxSwift

public protocol UberServiceViewModelProtocol {

    var input: UberServiceViewModelInput { get }
    var output: UberServiceViewModelOutput { get }
}

public protocol UberServiceViewModelInput {

    var selectedPlacePublisher: PublishSubject<UberData> { get }
    var requestUberPublisher: PublishSubject<Void> { get }
}

public struct UberData {

    public var placeObj: PlaceObj?
    public var from: CLLocationCoordinate2D

    public init(placeObj: PlaceObj?, from: CLLocationCoordinate2D) {
        self.placeObj = placeObj
        self.from = from
    }
}

public protocol UberServiceViewModelOutput {

    // Request Uber
    var availableGroupProductsDriver: Driver<[GroupProductObj]>! { get }
    var isLoadingAvailableProductPublisher: PublishSubject<Bool> { get }
    var selectedGroupProduct: Variable<GroupProductObj?> { get }
    var selectedProduct: Variable<ProductObj?> { get }

    // Surge Href
    var showSurgeHrefDriver: Driver<String>! { get }
}

open class UberServiceViewModel: BaseViewModel,
                                 UberServiceViewModelProtocol,
                                 UberServiceViewModelInput,
                                 UberServiceViewModelOutput {

    // MARK: - View Model
    public var input: UberServiceViewModelInput { return self }
    public var output: UberServiceViewModelOutput { return self }

    // MARK: - Input
    public var selectedPlacePublisher = PublishSubject<UberData>()
    public var requestUberPublisher = PublishSubject<Void>()

    // MARK: - Output
    public var availableGroupProductsDriver: Driver<[GroupProductObj]>!
    public var isLoadingAvailableProductPublisher = PublishSubject<Bool>()
    public let selectedGroupProduct = Variable<GroupProductObj?>(nil)
    public let selectedProduct = Variable<ProductObj?>(nil)
    public var showSurgeHrefDriver: Driver<String>!

    // MARK: - Variable
    fileprivate var uberService = UberService()
    fileprivate var uberData: UberData?

    // MARK: - Init
    override public init() {
        super.init()

        // Get available Product + Estimate price
        let selectionShared =
            self.selectedPlacePublisher
            .do(onNext: {[unowned self] _ in
                self.isLoadingAvailableProductPublisher.onNext(true)
            })
            .flatMapLatest {[unowned self] data -> Observable<[ProductObj]> in
                guard let placeObj = data.placeObj else {
                    return Observable.just([])
                }

                self.uberData = data
                return self.uberService.productsWithEstimatePriceObserver(from: data.from,
                                                                          to: placeObj.coordinate2D!)
            }
            .map({ GroupProductObj.mapProductGroups(from: $0) })
            .share()

        // Data
        self.availableGroupProductsDriver = selectionShared
                                            .asDriver(onErrorJustReturn: [])

        // Default selection
        selectionShared.map { (groups) -> GroupProductObj? in
            return groups.first
        }.bind(to: self.selectedGroupProduct)
        .addDisposableTo(self.disposeBag)

        selectionShared.map { (groups) -> ProductObj? in
            return groups.first?.productObjs.first
        }.bind(to: self.selectedProduct)
        .addDisposableTo(self.disposeBag)

        // Request Uber service
        self.requestUberPublisher.flatMapLatest {[unowned self] _ -> Observable<EstimateObj> in
            guard let productObj = self.selectedProduct.value else {
                return Observable.empty()
            }
            guard let data = self.uberData,
                  let placeObj = data.placeObj else {
                return Observable.empty()
            }
            Logger.info("productID = \(productObj.productId ?? "")")
            return self.uberService.estimateForSpecificProductObserver(productObj,
                                                                       from: data.from,
                                                                       to: placeObj.coordinate2D!)
        }
        .subscribe(onNext: { estimateObj in

            // Normal Price
            if let fareObj = estimateObj.upFrontFareObj {
                Logger.info("Normal Price")
                Logger.info("FareID = \(fareObj.fareId ?? "")")
            }

            // High surge rate
            if estimateObj.surgePriceObj != nil {
                Logger.info("High surge rate")
                NotificationService.postNotificationOnMainThreadType(.showSurgeHrefConfirmationView,
                                                                     object: estimateObj,
                                                                     userInfo: nil)
            }
        })
        .addDisposableTo(self.disposeBag)
    }
}
