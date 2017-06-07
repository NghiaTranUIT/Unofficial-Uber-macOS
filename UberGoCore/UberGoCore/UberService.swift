//
//  UberNetwork.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/2/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxOptional

open class UberService {

    // MARK: - Variable

    // MARK: - Init

    // MARK: - Public
    public func personalPlaceObserver() -> Observable<[PlaceObj]> {
        return Observable.zip([self.workPlaceObserver(), self.homePlaceObserver()])
    }

    public func workPlaceObserver() -> Observable<PlaceObj> {
        let param = UberPersonalPlaceRequestParam(placeType: .work)
        return self.personalPlaceObserable(param)
    }

    public func homePlaceObserver() -> Observable<PlaceObj> {
        let param = UberPersonalPlaceRequestParam(placeType: .home)
        return self.personalPlaceObserable(param)
    }
}

// MARK: - Private
extension UberService {

    fileprivate func personalPlaceObserable(_ param: UberPersonalPlaceRequestParam) -> Observable<PlaceObj> {

        guard UserObj.currentUser != nil else {
            return Observable<PlaceObj>.empty()
        }

        return UberPersonalPlaceRequest(param).toObservable()
            .map({ placeObj -> PlaceObj? in

                //FIXME : // Smell code - Ref Requestable.swift
                // For further information
                if placeObj.invalid {
                    return nil
                }
                return placeObj
            })
            .flatMapLatest({ placeObj -> Observable<PlaceObj> in

                if let placeObj = placeObj {
                    return Observable<PlaceObj>.just(placeObj)
                }

                return Observable<PlaceObj>.empty()
            })
    }
}
