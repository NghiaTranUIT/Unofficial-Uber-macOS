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
    public func personalPlaceObserver() -> Observable<[PlaceObj]> {
        return Observable.zip([workPlaceObserver(), homePlaceObserver()])
    }

    public func workPlaceObserver() -> Observable<PlaceObj> {
        return placeFromPersonalPlaceObserve(type: .work)
    }

    public func homePlaceObserver() -> Observable<PlaceObj> {
        return placeFromPersonalPlaceObserve(type: .home)
    }

    public func getCurrentTrip() -> Observable<TripObj> {
        return GetCurrentTripRequest().toObservable()
    }

    public func cancelCurrentTrip() -> Observable<Void> {
        return CancelCurrentTripRequest().toObservable()
        .map({ _ -> Void in
            return
        })
    }

    fileprivate class func historyPlaceObserver() -> Observable<[PlaceObj]> {

        return Observable<[PlaceObj]>.create({ (observer) -> Disposable in

            let currentUser = UberAuth.share.currentUser!
            let histories = currentUser.historyPlace()

            observer.onNext(histories)
            observer.onCompleted()

            return Disposables.create()
        })
    }

    // MARK: - Get Estimation + Available Uber
    public func productsWithEstimatePriceObserver(data: UberRequestTripData)
        -> Observable<[ProductObj]> {

            let productsOb = self.availableProductsObserver(at: data.from.coordinate2D)
            let estimatePriceOb = self.estimatePriceObserver(from: data.from.coordinate2D,
                                                             to: data.to.coordinate2D)
            let estimateTimeOb = self.estimateTimeObserver(from: data.from.coordinate2D)

            // Zip
            // Require to wait all out-going requrst
            return Observable.zip(productsOb, estimatePriceOb, estimateTimeOb)
                .map({ (products, estimatePrices, estimateTimes) -> [ProductObj] in

                    // Map Estimate Prict to individual productObj
                    // Compare by productID
                    let _products = products.map({ (product) -> ProductObj in

                        // Price
                        let price = estimatePrices.first(where: { $0.productId == product.productId })
                        if let price = price {
                            product.estimatePrice = price
                        }

                        // Time
                        let time = estimateTimes.first(where: { $0.productId == product.productId })
                        if let time = time {
                            product.estimateTime = time
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

    public func estimateTimeObserver(from originLocation: CLLocationCoordinate2D) -> Observable<[TimeEstimateObj]> {
            let param = RideEstimateTimeRequestParam(from: originLocation, productID: nil)
            return RideEstimateTimeRequest(param).toObservable()
    }

    // MARK: - Payment
    public func paymentMethodObserver() -> Observable<PaymentObj> {
        return GetPaymentMethodRequest().toObservable()
    }

    // MARK: - Request Uber
    public func estimateForSpecificProductObserver(_ productObj: ProductObj, data: UberRequestTripData)
    -> Observable<EstimateObj> {
        let param = PostEstimateTripRequestParamter(productId: productObj.productId,
                                                    data: data)
        return PostEstimateTripRequest(param).toObservable()
    }

    public func requestUpFrontFareTrip(frontFareObj: UpFrontFareOb,
                                       productObj: ProductObj,
                                       paymentAccountObj: PaymentAccountObj?,
                                       requestData: UberRequestTripData) -> Observable<CreateTripObj> {
        let param = CreateTripRequestParam(fareID: frontFareObj.fareId,
                                       productID: productObj.productId,
                                       surgeConfirmationId: nil,
                                       paymentMethodId: paymentAccountObj?.paymentMethodId,
                                       data: requestData)
        return CreateTripRequest(param).toObservable()
    }

    public func requestSurgeTrip(surgeID: String,
                                 productObj: ProductObj,
                                 paymentAccountObj: PaymentAccountObj?,
                                 requestData: UberRequestTripData) -> Observable<CreateTripObj> {
        let param = CreateTripRequestParam(fareID: nil,
                                           productID: productObj.productId,
                                           surgeConfirmationId: surgeID,
                                           paymentMethodId: paymentAccountObj?.paymentMethodId,
                                           data: requestData)
        return CreateTripRequest(param).toObservable()
    }

    // MARK: - Product Detail
    public func requestPriceDetail(_ productID: String) -> Observable<ProductObj> {
        let param = PriceDetailRequestParam(productID: productID)
        return PriceDetailRequest(param).toObservable()
    }
}

// MARK: - Private
extension UberService {

    fileprivate func fetchPersonalPlaceObservable(type: PlaceType)
        -> Observable<UberPersonalPlaceObj> {

        guard UberAuth.share.currentUser != nil else {
            return Observable<UberPersonalPlaceObj>.empty()
        }

        let param = UberPersonalPlaceRequestParam(placeType: type)
        return UberPersonalPlaceRequest(param).toObservable()
            .catchErrorJustReturn(UberPersonalPlaceObj.invalidPlace)
            .map { $0.placeType = type; return $0 }
    }

    fileprivate func placeFromPersonalPlaceObserve(type: PlaceType) -> Observable<PlaceObj> {
        return fetchPersonalPlaceObservable(type: type)
            .flatMapLatest({ (personalObj) -> Observable<PlaceObj> in
                guard personalObj.invalid == false else {
                    return Observable.just(PlaceObj.invalid(by: personalObj))
                }

                return GoogleMapService().geocodingPlace(with: personalObj)
            })
    }
}
