//
//  SandboxUberService.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/20/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import ObjectMapper
import RxSwift

open class SandboxUberService {

    // MARK: - Public
    public func modifySandboxProductObserver(productObj: ProductObj,
                                             surgeRate: Float,
                                             available: Bool) -> Observable<BaseObj> {
        let param = SandboxUpdateProductRequestParam(productID: productObj.objectId,
                                                     surgeMultiplier: surgeRate,
                                                     driversAvailable: available)
        return SandboxUpdateProductRequest(param).toObservable()
    }
}
