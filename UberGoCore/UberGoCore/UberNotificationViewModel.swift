//
//  UberNotificationViewModel.swift
//  UberGoCore
//
//  Created by Nghia Tran on 8/30/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public protocol UberNotificationViewModelProtocol {

    var input: UberNotificationViewModelInput { get }
    var output: UberNotificationViewModelOutput { get }
}

public protocol UberNotificationViewModelInput {

}

public protocol UberNotificationViewModelOutput {

}

public class UberNotificationViewModel: UberNotificationViewModelProtocol,
                                     UberNotificationViewModelInput,
                                     UberNotificationViewModelOutput {

    // MARK: - Protocol
    public var input: UberNotificationViewModelInput { return self }
    public var output: UberNotificationViewModelOutput { return self }

    // MARK: - Service
    fileprivate var service: UberNotificationService

    // MARK: - Variable
    fileprivate let disposeBag = DisposeBag()

    // MARK: - Init
    init(service: UberNotificationService,
         appViewMode: AppViewModelProtocol,
         uberViewModel: UberServiceViewModelProtocol) {
        self.service = service

        // Handle show notification if need
        uberViewModel.output.currentTripStatusDriver
            .flatMapLatest({ (result) -> Driver<APIResult<TripObj>> in
                guard appViewMode.output.popoverStateVariable.value == .close else {
                    return Driver.empty()
                }
                return Driver.just(result)
            })
            .distinctUntilChanged { (old, new) -> Bool in

                // New state
                if old.isSucces && new.isSucces {
                    return old.rawValue.status == new.rawValue.status
                }

                // Both are error
                if old.isError && new.isError {
                    return true
                }

                // Different state
                return false
            }
            .drive(onNext: { (result) in
                service.notifyUberNotification(result)
            })
            .addDisposableTo(disposeBag)

    }
}
