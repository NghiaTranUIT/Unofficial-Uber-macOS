//
//  UberNotificationService.swift
//  UberGoCore
//
//  Created by Nghia Tran on 8/23/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation
import RxSwift

open class UberNotificationService {

    // MARK: - Variable
    public var handleTripResultObs: Observable<APIResult<TripObj>>!
    fileprivate let _service: UserNotificationServiceProtocol
    fileprivate let appViewModel: AppViewModel
    fileprivate let disposeBag = DisposeBag()

    // MARK: - Init
    init(service: UserNotificationServiceProtocol, appViewModel: AppViewModel) {
        _service = service
        self.appViewModel = appViewModel
    }

    // MARK: - Public
    public func binding(tripObs: Observable<APIResult<TripObj>>) {
        handleTripResultObs = tripObs

        // Notification
        handleTripResultObs.subscribe(onNext: { (result) in
            switch result {
            case .success(let trip):

                break
            case .error(let error):
                break
            }
        })
        .addDisposableTo(disposeBag)
    }
}

// MARK: - Private
extension UberNotificationService {

    fileprivate func notifyDriverComming(driver: DriverObj, vehicle: VehicleObj) {
        let action = DriverCommingAction(driver: driver, vehicle: vehicle)
        _service.publishAction(action)
    }

    fileprivate func notifyDriverAlready(driver: DriverObj, vehicle: VehicleObj) {
        let action = DriverAlreadyAction(driver: driver, vehicle: vehicle)
        _service.publishAction(action)
    }

    fileprivate func notifyTripSuccessful(receipt: ReceiptObj) {
        let action = TripSuccessfulAction(receipt: receipt)
        _service.publishAction(action)
    }

    fileprivate func notifyCancelTrip() {
        let action = CancelTripAction()
        _service.publishAction(action)
    }
}
