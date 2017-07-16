//
//  SandboxUberService.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/20/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Unbox
import RxSwift

open class SandboxUberService {

    // MARK: - Public
    public func modifySandboxProductObserver(productObj: ProductObj,
                                             surgeRate: Float,
                                             available: Bool) -> Observable<Void> {
        let param = SandboxUpdateProductRequestParam(productID: productObj.productId,
                                                     surgeMultiplier: surgeRate,
                                                     driversAvailable: available)
        return SandboxUpdateProductRequest(param).toObservable()
    }

    public func updateTripStateObserver(status: TripObjStatus,
                                        requestID: String) -> Observable<Void> {
        let param = SandboxUpdateStatusTripRequestParam(status: status, requestID: requestID)
        return SandboxUpdateStatusTripRequest(param).toObservable()
        .map({ (_) -> Void in
            return
        })
    }
}
