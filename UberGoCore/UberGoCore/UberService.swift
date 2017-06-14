//
//  UberNetwork.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/2/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation
import CoreLocation
import RxCocoa
import RxSwift

open class UberService {

    // MARK: - Variable

    // MARK: - Init

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

    public func availableProducts(at location: CLLocationCoordinate2D) -> Observable<[ProductObj]> {
        let param = UberProductsRequestParam(location: location)
        return UberProductsRequest(param).toObservable()
    }

    public func rideEstimatePrice(from originLocation: CLLocationCoordinate2D,
                                  to destinationLocation: CLLocationCoordinate2D)
        -> Observable<[PriceObj]> {
        let param = RideEstimatePriceRequestParam(originLocation: originLocation,
                                                  destinationLocation: destinationLocation)
        return RideEstimatePriceRequest(param).toObservable()
    }

    public func getCurrentRide() -> Observable<TripObj> {
        return GetCurrentTripRequest().toObservable()
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
