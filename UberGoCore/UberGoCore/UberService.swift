//
//  UberNetwork.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/2/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import CoreLocation
import RxCocoa
import RxSwift

open class UberService {

    // MARK: - Variable
    public let reloadHistoryTrigger = PublishSubject<Void>()
    public var historyObserver: Observable<[PlaceObj]>

    // MARK: - Init
    init() {

        self.historyObserver = self.reloadHistoryTrigger
            .asObserver()
            .flatMapLatest { (_) -> Observable<[PlaceObj]> in
                return UberService.historyPlaceObserver()
            }
    }

    // MARK: - Public
    public func personalPlaceObserver() -> Observable<[UberPersonalPlaceObj]> {
        return Observable.zip([self.workPlaceObserver(), self.homePlaceObserver()])
    }

    public func workPlaceObserver() -> Observable<UberPersonalPlaceObj> {
        let param = UberPersonalPlaceRequestParam(placeType: .work)
        return self.personalPlaceObserable(param)
            .do(onNext: { (place) in
                place.placeType = .work
            })
    }

    public func homePlaceObserver() -> Observable<UberPersonalPlaceObj> {
        let param = UberPersonalPlaceRequestParam(placeType: .home)
        return self.personalPlaceObserable(param)
            .do(onNext: { (place) in
                place.placeType = .home
            })
    }

    public func getCurrentRide() -> Observable<TripObj> {
        return GetCurrentTripRequest().toObservable()
    }

    fileprivate class func historyPlaceObserver() -> Observable<[PlaceObj]> {

        return Observable<[PlaceObj]>.create({ (observer) -> Disposable in

            let currentUser = UserObj.currentUser!
            let histories = currentUser.historyPlace()

            observer.onNext(histories)
            observer.onCompleted()

            return Disposables.create()
        })
    }

    // MARK: - Get Estimation + Available Uber
    public func productsWithEstimatePriceObserver(from originLocation: CLLocationCoordinate2D,
                                                  to destinationLocation: CLLocationCoordinate2D)
        -> Observable<[ProductObj]> {

            let productsOb = self.availableProductsObserver(at: originLocation)
            let estimateOb = self.estimatePriceObserver(from: originLocation, to: destinationLocation)

            return Observable.zip(productsOb, estimateOb).map({ (products, estimates) -> [ProductObj] in

                // Debug
                if products.count != estimates.count {
                    assert(false, "[ERROR]: Products's count != Estimate's count")
                }

                // Map Estimate Prict to individual productObj
                // Compare by productID
                let _products = products.map({ (product) -> ProductObj in
                    let price = estimates.first(where: { $0.productId == product.productId })
                    if let price = price {
                        product.estimatePrice = price
                    }
                    return product
                })

                return _products
            })
    }

    public func availableProductsObserver(at location: CLLocationCoordinate2D) -> Observable<[ProductObj]> {
        let param = UberProductsRequestParam(location: location)
        return UberProductsRequest(param).toObservable()
    }

    public func estimatePriceObserver(from originLocation: CLLocationCoordinate2D,
                                      to destinationLocation: CLLocationCoordinate2D)
        -> Observable<[PriceObj]> {
            let param = RideEstimatePriceRequestParam(from: originLocation,
                                                      to: destinationLocation)
            return RideEstimatePriceRequest(param).toObservable()
    }

    // MARK: - Payment
    public func paymentMethodObserver() -> Observable<PaymentObj> {
        return GetPaymentMethodRequest().toObservable()
    }

    // MARK: - Request Uber
    public func estimateForSpecificProductObserver(_ productObj: ProductObj,
                                                   from: CLLocationCoordinate2D,
                                                   to: CLLocationCoordinate2D)
    -> Observable<EstimateObj> {

        //TODO : Should support from personalPlace -> personalPlace as well
        // Currently, I only support physical location -> location
        let param = PostEstimateTripRequestParamter(productId: productObj.productId!,
                                                    startLocation: from,
                                                    endLocation: to,
                                                    startPlaceType: nil,
                                                    endPlaceType: nil)
        return PostEstimateTripRequest(param).toObservable()
    }

    public func requestUpFrontFareTrip(frontFareObj: UpFrontFareOb,
                                       productObj: ProductObj,
                                       paymentAccountObj: PaymentAccountObj?,
                                       from: CLLocationCoordinate2D,
                                       to: PlaceObj) -> Observable<CreateTripObj> {
        let param = CreateTripRequestParam(fareID: frontFareObj.fareId!,
                                       productID: productObj.productId!,
                                       surgeConfirmationId: nil,
                                       paymentMethodId: paymentAccountObj?.paymentMethodId,
                                       startLocation: from,
                                       endLocation: to.coordinate2D,
                                       startPlaceType: nil,
                                       endPlaceType: nil)
        return CreateTripRequest(param).toObservable()
    }

    public func requestSurgeTrip(surgeID: String,
                                 productObj: ProductObj,
                                 paymentAccountObj: PaymentAccountObj?,
                                 from: CLLocationCoordinate2D,
                                 to: PlaceObj) -> Observable<CreateTripObj> {
        let param = CreateTripRequestParam(fareID: nil,
                                       productID: productObj.productId!,
                                       surgeConfirmationId: surgeID,
                                       paymentMethodId: paymentAccountObj?.paymentMethodId,
                                       startLocation: from,
                                       endLocation: to.coordinate2D,
                                       startPlaceType: nil,
                                       endPlaceType: nil)
        return CreateTripRequest(param).toObservable()
    }
}

// MARK: - Private
extension UberService {

    fileprivate func personalPlaceObserable(_ param: UberPersonalPlaceRequestParam)
        -> Observable<UberPersonalPlaceObj> {

        guard UserObj.currentUser != nil else {
            return Observable<UberPersonalPlaceObj>.empty()
        }

        return UberPersonalPlaceRequest(param).toObservable()
            .map({ placeObj -> UberPersonalPlaceObj? in

                //FIXME : // Smell code - Ref Requestable.swift
                // For further information
                if placeObj.invalid {
                    return nil
                }
                return placeObj
            })
            .flatMapLatest({ placeObj -> Observable<UberPersonalPlaceObj> in

                if let placeObj = placeObj {
                    return Observable<UberPersonalPlaceObj>.just(placeObj)
                }

                return Observable<UberPersonalPlaceObj>.empty()
            })
    }
}
