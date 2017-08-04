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

    var selectedPlacePublisher: PublishSubject<UberTripData?> { get }
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
    var availableGroupProductsDriver: Driver<APIResult<[GroupProductObj]>> { get }
    var requestUberEstimationSuccessDriver: Driver<APIResult<UberTripData>> { get }
    var isLoadingDriver: Driver<Bool> { get }
    var selectedGroupProduct: Variable<GroupProductObj?> { get }
    var selectedProduct: Variable<ProductObj?> { get }

    // Surge Href
    var showSurgeHrefDriver: Driver<SurgePriceObj> { get }

    // Normal Trip
    var normalTripDriver: Driver<CreateTripObj>! { get }

    // Current Trip Status
    var currentTripStatusDriver: Driver<APIResult<TripObj>>! { get }
    var manuallyCurrentTripStatusDriver: Driver<APIResult<TripObj>>! { get }

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
    public var selectedPlacePublisher = PublishSubject<UberTripData?>()
    public var requestUberPublisher = PublishSubject<Void>()

    // MARK: - Output
    public var availableGroupProductsDriver: Driver<APIResult<[GroupProductObj]>>
    public var requestUberEstimationSuccessDriver: Driver<APIResult<UberTripData>>
    public var isLoadingDriver: Driver<Bool>
    public let selectedGroupProduct = Variable<GroupProductObj?>(nil)
    public let selectedProduct = Variable<ProductObj?>(nil)
    public var showSurgeHrefDriver: Driver<SurgePriceObj>
    public var normalTripDriver: Driver<CreateTripObj>!
    public var requestUberWithSurgeIDPublisher = PublishSubject<String>()
    public var currentTripStatusDriver: Driver<APIResult<TripObj>>!
    public var triggerCurrentTripPublisher = PublishSubject<Void>()
    public var manuallyGetCurrentTripStatusPublisher = PublishSubject<Void>()
    public var manuallyCurrentTripStatusDriver: Driver<APIResult<TripObj>>!
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
        let selectionShared = selectedPlacePublisher
            .asObserver()
            .share()

        // Load
        isLoadingDriver = selectionShared
            .map({ (_) -> Bool in return true })
            .asDriver(onErrorJustReturn: false)

        // Bind to Uber Trip
        selectionShared
            .bind(to: uberData)
            .addDisposableTo(disposeBag)

        // Request Products + Estimations
        let groupProductShared = selectionShared
            .filterNil()
            .flatMapLatest { data -> Observable<[ProductObj]> in
                return uberService.productsWithEstimatePriceObserver(from: data.from,
                                                                       to: data.to.coordinate2D)
            }
            .map({ GroupProductObj.mapProductGroups(from: $0) })
            .share()

        let resultGroupProducts = groupProductShared
            .map({ return APIResult(rawValue: $0)! })

        requestUberEstimationSuccessDriver = resultGroupProducts
            .withLatestFrom(selectionShared.asObservable())
            .filterNil()
            .map({ return APIResult(rawValue: $0)! })
            .asDriver { return .just(APIResult<UberTripData>(errorValue: $0)) }

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
        let productNil = selectionShared.flatMapLatest { (data) -> Observable<ProductObj?> in
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
            .withLatestFrom(uberData.asObservable())
            .filterNil()
            .withLatestFrom(selectedProduct.asObservable(),
                            resultSelector: { (tripData, productObj) -> (UberTripData, ProductObj) in
                return (tripData, productObj!)
            })
            .flatMapLatest { data -> Observable<EstimateObj> in
                let productObj = data.1
                Logger.info("productID = \(productObj.productId)")
                return uberService.estimateForSpecificProductObserver(productObj,
                                                                           from: data.0.from,
                                                                           to: data.0.to.coordinate2D)
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
            .flatMapLatest { (estiamteObj) -> Observable<CreateTripObj>in

                // Guard
                guard
                let frontFareObj = estiamteObj.upFrontFareObj,
                let productObj = self.selectedProduct.value,
                let currentUser = UberAuth.share.currentUser,
                let data = self.uberData.value else {
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
        let uberTripSurgeFareOb = requestUberWithSurgeIDPublisher
            .asObserver()
            .flatMapLatest {[unowned self] (urlPath) -> Observable<CreateTripObj> in

                let url = URL(string: urlPath)!
                guard let ID = url.queryItemForKey(key: "surge_confirmation_id")?.value else {
                    return Observable.empty()
                }
                guard let productObj = self.selectedProduct.value else {
                    return Observable.empty()
                }
                guard let currentUser = UberAuth.share.currentUser else {
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

        normalTripDriver = Observable
            .merge([uberTripUpFareOb, uberTripSurgeFareOb])
            .asDriver(onErrorJustReturn: CreateTripObj.invalid)

        //FIXME : For some reason: Merge<timerObj, manuallyTriggerOb> cause timer didn't fire up
        // Manually trigger at the first time app open
        manuallyCurrentTripStatusDriver =
            manuallyGetCurrentTripStatusPublisher
            .asObserver()
            .flatMapLatest { _ -> Observable<APIResult<TripObj>> in
                return uberService
                        .getCurrentTrip()
                        .map({ APIResult(rawValue: $0)! })
            }
            .asDriver { Driver.just(APIResult<TripObj>(errorValue: $0)) }

        // cancel
        let cancelTripObser = cancelCurrentTripPublisher
            .asObserver()
            .flatMapLatest { _ -> Observable<Void> in
                uberService.cancelCurrentTrip()
            }

        resetMapDriver = cancelTripObser
            .asDriver(onErrorJustReturn: ())

        // Current Trip Status
        let timerOb = triggerCurrentTripPublisher
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
        currentTripStatusDriver =
            //Observable.merge([timerOb, tripTriggerManually])
            timerOb
            .flatMapLatest { _ -> Observable<APIResult<TripObj>> in
                Logger.debug("$$$ TIMER start")
                return uberService.getCurrentTrip().map({ APIResult(rawValue: $0)! })
            }
            .do(onNext: { (result) in
                let tripObj = result.rawValue
                if tripObj.isValidTrip == false {
                    Logger.error("Invalid timer")
                    self.timerDisposeBag = DisposeBag()
                }
            }, onError: {[unowned self] _ in
                Logger.error("Invalid timer")
                self.timerDisposeBag = DisposeBag()
            })
            .asDriver { Driver.just(APIResult<TripObj>(errorValue: $0)) }
    }
}
