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

    var selectedPlacePublisher: PublishSubject<UberTripData> { get }
    var requestUberPublisher: PublishSubject<Void> { get }
    var requestUberWithSurgeIDPublisher: PublishSubject<String> { get }

    var triggerCurrentTripPublisher: PublishSubject<Void> { get }
    var manuallyGetCurrentTripStatusPublisher: PublishSubject<Void> { get }
    var cancelCurrentTripPublisher: PublishSubject<Void> { get }
}

public struct UberTripData {

    public var to: PlaceObj
    public var from: CLLocationCoordinate2D

    public init(to: PlaceObj,
                from: CLLocationCoordinate2D) {
        self.to = to
        self.from = from
    }
}

public protocol UberServiceViewModelOutput {

    // Request Uber
    var availableGroupProductsDriver: Driver<[GroupProductObj]> { get }
    var isLoadingDriver: Driver<Bool> { get }
    var selectedGroupProduct: Variable<GroupProductObj?> { get }
    var selectedProduct: Variable<ProductObj?> { get }

    // Surge Href
    var showSurgeHrefDriver: Driver<SurgePriceObj> { get }

    // Normal Trip
    var normalTripDriver: Driver<CreateTripObj>! { get }

    // Current Trip Status
    var currentTripStatusDriver: Driver<TripObj>! { get }
    var manuallyCurrentTripStatusDriver: Driver<TripObj>! { get }

    // Reset map
    var resetMapDriver: Driver<Void>! { get }
}

open class UberServiceViewModel: UberServiceViewModelProtocol,
                                 UberServiceViewModelInput,
                                 UberServiceViewModelOutput {

    // MARK: - View Model
    public var input: UberServiceViewModelInput { return self }
    public var output: UberServiceViewModelOutput { return self }

    // MARK: - Input
    public var selectedPlacePublisher = PublishSubject<UberTripData>()
    public var requestUberPublisher = PublishSubject<Void>()

    // MARK: - Output
    public var availableGroupProductsDriver: Driver<[GroupProductObj]>
    public var isLoadingDriver: Driver<Bool>
    public let selectedGroupProduct = Variable<GroupProductObj?>(nil)
    public let selectedProduct = Variable<ProductObj?>(nil)
    public var showSurgeHrefDriver: Driver<SurgePriceObj>
    public var normalTripDriver: Driver<CreateTripObj>!
    public var requestUberWithSurgeIDPublisher = PublishSubject<String>()
    public var currentTripStatusDriver: Driver<TripObj>!
    public var triggerCurrentTripPublisher = PublishSubject<Void>()
    public var manuallyGetCurrentTripStatusPublisher = PublishSubject<Void>()
    public var manuallyCurrentTripStatusDriver: Driver<TripObj>!
    public var cancelCurrentTripPublisher = PublishSubject<Void>()
    public var resetMapDriver: Driver<Void>!

    // MARK: - Variable
    fileprivate var uberService: UberService
    fileprivate let uberData = Variable<UberTripData?>(nil)

    // Dispose
    fileprivate let disposeBag = DisposeBag()
    fileprivate var timerDisposeBag = DisposeBag()

    // MARK: - Init
    public init(uberService: UberService = UberService()) {

        self.uberService = uberService

        // Get available Product + Estimate price
        let selectionShared = self.selectedPlacePublisher
            .asObserver()
            .share()

        // Load
        self.isLoadingDriver = selectionShared
            .map({ _ -> Bool in
                return true
            })
            .asDriver(onErrorJustReturn: false)

        // Bind to Uber Trip
        selectionShared
            .bind(to: self.uberData)
            .addDisposableTo(self.disposeBag)

        // Request Products + Estimation
        let groupProductShared = selectionShared
            .flatMapLatest { data -> Observable<[ProductObj]> in
                return uberService.productsWithEstimatePriceObserver(from: data.from,
                                                                       to: data.to.coordinate2D!)
            }
            .map({ GroupProductObj.mapProductGroups(from: $0) })
            .share()

        // Data
        self.availableGroupProductsDriver = groupProductShared
                                            .asDriver(onErrorJustReturn: [])

        // Default selection
        groupProductShared
            .map { return $0.first }
            .bind(to: self.selectedGroupProduct)
            .addDisposableTo(self.disposeBag)

        groupProductShared
            .map { $0.first?.productObjs.first }
            .bind(to: self.selectedProduct)
            .addDisposableTo(self.disposeBag)

        // Request Uber service
        let shareRequest = self.requestUberPublisher
            .withLatestFrom(self.uberData.asObservable())
            .filterNil()
            .withLatestFrom(self.selectedProduct.asObservable(),
                            resultSelector: { (tripData, productObj) -> (UberTripData, ProductObj) in
                return (tripData, productObj!)
            })
            .flatMapLatest { data -> Observable<EstimateObj> in
                let productObj = data.1
                Logger.info("productID = \(productObj.productId ?? "")")
                return uberService.estimateForSpecificProductObserver(productObj,
                                                                           from: data.0.from,
                                                                           to: data.0.to.coordinate2D!)
            }
            .share()

        // Show Surge rate confirmation
        self.showSurgeHrefDriver = shareRequest
            .flatMapFirst { (estimateObj) -> Observable<SurgePriceObj> in
                guard let surgePriceObj = estimateObj.surgePriceObj else {
                    return Observable.empty()
                }
                guard surgePriceObj.surgeConfirmationHref != nil else {
                    assert(false, "surgeConfirmationHref is nill")
                }
                return Observable.just(surgePriceObj)
            }
            .asDriver(onErrorJustReturn: SurgePriceObj())

        // Normal Price
        let uberTripUpFareOb = shareRequest
            .flatMapLatest { (estiamteObj) -> Observable<CreateTripObj>in

                // Guard
                //FIXME : Should refactor after refactoring JSON Mapping
                guard let frontFareObj = estiamteObj.upFrontFareObj else {
                    return Observable.empty()
                }
                guard let productObj = self.selectedProduct.value else {
                    return Observable.empty()
                }
                guard let currentUser = UserObj.currentUser else {
                    return Observable.empty()
                }
                guard let data = self.uberData.value else {
                    return Observable.empty()
                }

                let payment = currentUser.currentPaymentAccountObjVar.value
                Logger.info("Normal Price")
                return self.uberService.requestUpFrontFareTrip(frontFareObj: frontFareObj,
                                                               productObj: productObj,
                                                               paymentAccountObj: payment,
                                                               from: data.from,
                                                               to: data.to)
            }

        // Handle SurgeCallback
        let uberTripSurgeFareOb = self.requestUberWithSurgeIDPublisher
            .asObserver()
            .flatMapLatest {[unowned self] (urlPath) -> Observable<CreateTripObj> in

                let url = URL(string: urlPath)!
                guard let ID = url.queryItemForKey(key: "surge_confirmation_id")?.value else {
                    return Observable.empty()
                }
                guard let productObj = self.selectedProduct.value else {
                    return Observable.empty()
                }
                guard let currentUser = UserObj.currentUser else {
                    return Observable.empty()
                }
                guard let data = self.uberData.value else {
                    return Observable.empty()
                }
                let payment = currentUser.currentPaymentAccountObjVar.value
                return uberService.requestSurgeTrip(surgeID: ID,
                                                 productObj: productObj,
                                          paymentAccountObj: payment,
                                                 from: data.from,
                                                 to: data.to)
            }

        self.normalTripDriver = Observable.merge([uberTripUpFareOb, uberTripSurgeFareOb])
            .asDriver(onErrorJustReturn: CreateTripObj())

        //FIXME : For some reason: Merge<timerObj, manuallyTriggerOb> cause timer didn't fire up
        // Manually trigger at the first time app open
        self.manuallyCurrentTripStatusDriver = self.manuallyGetCurrentTripStatusPublisher
            .asObserver()
            .flatMapLatest { _ -> Observable<TripObj> in
                return uberService.getCurrentTrip()
            }
            .asDriver(onErrorJustReturn: TripObj.noCurrentTrip())

        // cancel
        self.resetMapDriver = self.cancelCurrentTripPublisher.asObserver()
            .flatMapLatest { _ -> Observable<Void> in
                uberService.cancelCurrentTrip()
            }
            .asDriver(onErrorJustReturn: ())

        // Current Trip Status
        let timerOb = self.triggerCurrentTripPublisher
            .asObserver()
            .do(onNext: { _ in

                // Invalidate Timer
                self.timerDisposeBag = DisposeBag()
            })
            .flatMapLatest { _ -> Observable<Int> in
                return Observable<Int>
                    .interval(10, scheduler: MainScheduler.instance)
                    .startWith(1) // Call instantly
            }

        // Merge
        self.currentTripStatusDriver =
            //Observable.merge([timerOb, tripTriggerManually])
            timerOb
            .flatMapLatest { _ -> Observable<TripObj> in
                Logger.debug("$$$ TIMER start")
                return uberService.getCurrentTrip()
            }
            .do(onNext: { (tripObj) in
                if tripObj.isValidTrip == false {
                    Logger.error("Invalid timer")
                    self.timerDisposeBag = DisposeBag()
                }
            }, onError: {[unowned self] _ in
                Logger.error("Invalid timer")
                self.timerDisposeBag = DisposeBag()
            })
            .asDriver(onErrorJustReturn: TripObj.noCurrentTrip())
    }
}
