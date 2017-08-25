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

    var requestEstimateTripPublish: PublishSubject<UberRequestTripData?> { get }
    var requestUberPublisher: PublishSubject<Void> { get }
    var requestUberWithSurgeIDPublisher: PublishSubject<String> { get }

    var triggerCurrentTripPublisher: PublishSubject<Void> { get }
    var cancelCurrentTripPublisher: PublishSubject<Void> { get }
}

public protocol UberServiceViewModelOutput {

    // Request Uber
    var availableGroupProductsDriver: Driver<APIResult<[GroupProductObj]>> { get }
    var requestUberEstimationSuccessDriver: Driver<APIResult<UberRequestTripData>> { get }
    var isLoadingDriver: Driver<Bool> { get }
    var selectedGroupProduct: Variable<GroupProductObj?> { get }
    var selectedProduct: Variable<ProductObj?> { get }

    // Surge Href
    var showSurgeHrefDriver: Driver<SurgePriceObj> { get }

    // Normal Trip
    var normalTripDriver: Driver<CreateTripObj>! { get }

    // Current Trip Status
    var currentTripStatusDriver: Driver<APIResult<TripObj>>! { get }

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
    public var requestEstimateTripPublish = PublishSubject<UberRequestTripData?>()
    public var requestUberPublisher = PublishSubject<Void>()

    // MARK: - Output
    public var availableGroupProductsDriver: Driver<APIResult<[GroupProductObj]>>
    public var requestUberEstimationSuccessDriver: Driver<APIResult<UberRequestTripData>>
    public var isLoadingDriver: Driver<Bool>
    public let selectedGroupProduct = Variable<GroupProductObj?>(nil)
    public let selectedProduct = Variable<ProductObj?>(nil)
    public var showSurgeHrefDriver: Driver<SurgePriceObj>
    public var normalTripDriver: Driver<CreateTripObj>!
    public var requestUberWithSurgeIDPublisher = PublishSubject<String>()
    public var currentTripStatusDriver: Driver<APIResult<TripObj>>!
    public var triggerCurrentTripPublisher = PublishSubject<Void>()
    public var manuallyGetCurrentTripStatusPublisher = PublishSubject<Void>()
    public var cancelCurrentTripPublisher = PublishSubject<Void>()
    public var resetMapDriver: Driver<Void>!

    // MARK: - Variable
    fileprivate var uberService: UberService

    // Timer
    fileprivate let timerInterval = 5.0
    fileprivate let timerFirePublisher = PublishSubject<Void>()
    fileprivate var timer: Timer?

    // Dispose
    fileprivate let disposeBag = DisposeBag()

    // MARK: - Init
    public init(uberService: UberService) {
        self.uberService = uberService

        // Get available Product + Estimate price
        let requestEstimateTripShare = requestEstimateTripPublish
            .asObserver()
            .share()

        // Load
        isLoadingDriver = requestEstimateTripShare
            .map({ (_) -> Bool in return true })
            .asDriver(onErrorJustReturn: false)

        // Request Products + Estimations
        let groupProductShared = requestEstimateTripShare
            .filterNil()
            .flatMapLatest { data -> Observable<[ProductObj]> in
                return uberService.productsWithEstimatePriceObserver(data: data)
            }
            .map({ GroupProductObj.mapProductGroups(from: $0) })
            .share()

        let resultGroupProducts = groupProductShared
            .map({ return APIResult(rawValue: $0)! })

        requestUberEstimationSuccessDriver = resultGroupProducts
            .withLatestFrom(requestEstimateTripShare)
            .filterNil()
            .map({ return APIResult(rawValue: $0)! })
            .asDriver { return .just(APIResult<UberRequestTripData>(errorValue: $0)) }

        // Data
        availableGroupProductsDriver = resultGroupProducts
            .asDriver { return .just(APIResult<[GroupProductObj]>(errorValue: $0)) }

        // Default selection
        let groupProductSharedNoError = groupProductShared
                                            .catchErrorJustReturn([])
        groupProductSharedNoError
            .map { return $0.first }
            .bind(to: selectedGroupProduct)
            .addDisposableTo(disposeBag)

        // Nil
        let productNil = requestEstimateTripShare
            .flatMapLatest { (data) -> Observable<ProductObj?> in
                if data == nil {
                    return Observable.just(nil)
                }
                return Observable.empty()
            }

        let defaultFirstObj = groupProductSharedNoError
            .map { $0.first?.productObjs.first }

        Observable.merge([productNil, defaultFirstObj])
            .bind(to: selectedProduct)
            .addDisposableTo(disposeBag)

        // Request Uber service
        let shareRequest = requestUberPublisher
            .withLatestFrom(requestEstimateTripPublish.asObserver())
            .filterNil()
            .withLatestFrom(selectedProduct.asObservable(),
                            resultSelector: { (tripData, productObj) -> (UberRequestTripData, ProductObj) in
                return (tripData, productObj!)
            })
            .flatMapLatest { tuple -> Observable<EstimateObj> in
                let uberTripData = tuple.0
                let productObj = tuple.1
                Logger.info("productID = \(productObj.productId)")
                return uberService.estimateForSpecificProductObserver(productObj,
                                                                      data: uberTripData)
            }
            .share()

        // Show Surge rate confirmation
        showSurgeHrefDriver = shareRequest
            .flatMapFirst { (estimateObj) -> Observable<SurgePriceObj> in
                guard let surgePriceObj = estimateObj.surgePriceObj else {
                    return Observable.empty()
                }
                guard surgePriceObj.surgeConfirmationHref != nil else {
                    assert(false, "surgeConfirmationHref is nill")
                    return Observable.empty()
                }
                return Observable.just(surgePriceObj)
            }
            .asDriver(onErrorJustReturn: SurgePriceObj.invalid)

        // Normal Price
        let uberTripUpFareOb = shareRequest
            .flatMapLatest({ (estimateObj) -> Observable<UpFrontFareOb> in
                guard let frontFareObj = estimateObj.upFrontFareObj else {
                    return .empty()
                }
                return .just(frontFareObj)
            })
            .withLatestFrom(requestEstimateTripShare
                .asObservable()
                .filterNil(), resultSelector: { (frontFareObj, data) -> (UpFrontFareOb, UberRequestTripData) in
                return (frontFareObj, data)
            })
            .flatMapLatest {[unowned self](tuble) -> Observable<CreateTripObj>in

                // Guard
                guard
                let productObj = self.selectedProduct.value,
                let currentUser = UberAuth.share.currentUser
                else { return .empty() }

                let data = tuble.1
                let frontFareObj = tuble.0
                let payment = currentUser.currentPaymentAccountObjVar.value
                Logger.info("Normal Price")
                return self.uberService.requestUpFrontFareTrip(frontFareObj: frontFareObj,
                                                               productObj: productObj,
                                                               paymentAccountObj: payment,
                                                               requestData: data)
            }

        // Handle SurgeCallback
        let uberTripSurgeFareOb = requestUberWithSurgeIDPublisher
            .asObserver()
            .withLatestFrom(requestEstimateTripShare
                .asObservable()
                .filterNil(), resultSelector: { (path, data) -> (String, UberRequestTripData) in
                return (path, data)
            })
            .flatMapLatest {[unowned self] (tuble) -> Observable<CreateTripObj> in

                let url = URL(string: tuble.0)!
                guard let ID = url.queryItemForKey(key: "surge_confirmation_id")?.value else {
                    return Observable.empty()
                }
                guard let productObj = self.selectedProduct.value else {
                    return Observable.empty()
                }
                guard let currentUser = UberAuth.share.currentUser else {
                    return Observable.empty()
                }
                let requestData = tuble.1
                let payment = currentUser.currentPaymentAccountObjVar.value
                return uberService.requestSurgeTrip(surgeID: ID,
                                                 productObj: productObj,
                                          paymentAccountObj: payment,
                                          requestData: requestData)
            }

        normalTripDriver = Observable
            .merge([uberTripUpFareOb, uberTripSurgeFareOb])
            .asDriver(onErrorJustReturn: CreateTripObj.invalid)

        // cancel
        let cancelTripObser = cancelCurrentTripPublisher
            .asObserver()
            .flatMapLatest { _ -> Observable<Void> in
                uberService.cancelCurrentTrip()
            }

        resetMapDriver = cancelTripObser
            .asDriver(onErrorJustReturn: ())

        triggerCurrentTripPublisher
        .asObserver()
            .subscribe(onNext: {[weak self] (_) in
                guard let `self` = self else {
                    return
                }
                self.startTripTimer()
            })
        .disposed(by: disposeBag)

        let currentStatusObs = timerFirePublisher
            .asObserver()
            .flatMapLatest { (_) -> Observable<APIResult<TripObj>> in
                Logger.debug("$$$ tripTimerFire start")
                return uberService
                        .getCurrentTrip()
                        .map({ APIResult(rawValue: $0)! })
                        .catchError({ (error) -> Observable<APIResult<TripObj>> in
                            return Observable.just(APIResult<TripObj>(errorValue: error))
                        })
            }
            .do(onNext: {[weak self] (result) in
                guard let `self` = self else { return }

                // Error
                if result.isError {
                    self.invalideTripTimer()
                    return
                }

                // Success
                let tripObj = result.rawValue
                if tripObj.isValidTrip == false {
                    self.invalideTripTimer()
                }
            })

        // Merge
        currentTripStatusDriver = currentStatusObs
            .asDriver { Driver.just(APIResult<TripObj>(errorValue: $0)) }
    }
}

// MARK: - Timer
extension UberServiceViewModel {

    fileprivate func invalideTripTimer() {
        guard timer != nil else { return }

        Logger.error("Invalid timer")

        // Validate
        timer?.invalidate()
        timer = nil
    }

    fileprivate func startTripTimer() {

        // Invalide if need
        invalideTripTimer()

        // Init
        timer = Timer.scheduledTimer(timeInterval: timerInterval,
                                     target: self,
                                     selector: #selector(self.tripTimerFire),
                                     userInfo: nil,
                                     repeats: true)
        timer?.fire()
    }

    @objc fileprivate func tripTimerFire() {
        timerFirePublisher.onNext()
    }
}
