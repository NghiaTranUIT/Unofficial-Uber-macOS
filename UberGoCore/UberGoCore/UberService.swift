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
    public func personalPlaceObserver() -> Observable<[UberPersonalPlaceObj]> {
        return Observable.zip([self.workPlaceObserver(), self.homePlaceObserver()])
    }

    public func workPlaceObserver() -> Observable<UberPersonalPlaceObj> {
        let param = UberPersonalPlaceRequestParam(placeType: .work)
        return self.personalPlaceObserable(param)
    }

    public func homePlaceObserver() -> Observable<UberPersonalPlaceObj> {
        let param = UberPersonalPlaceRequestParam(placeType: .home)
        return self.personalPlaceObserable(param)
    }
}

// MARK: - Private
extension UberService {

    fileprivate func personalPlaceObserable(_ param: UberPersonalPlaceRequestParam) -> Observable<UberPersonalPlaceObj> {

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
