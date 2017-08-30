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
    fileprivate let _service: UserNotificationServiceProtocol
    fileprivate let disposeBag = DisposeBag()

    // MARK: - Init
    init(service: UserNotificationServiceProtocol = NotificationService()) {
        _service = service
    }

    public func notifyUberNotification(_ result: APIResult<TripObj>) {

        switch result {
        case .success(let trip):
            handleUberNotification(with: trip)

        case .error(let error):
            handleErrorNotification(with: error)
        }
    }

    fileprivate func handleUberNotification(with trip: TripObj) {

        switch trip.status {
        case .driverCanceled:
            Logger.info("[Uber Notification] : notifyCancelTrip ")
            notifyCancelTrip()

        case .accepted:
            Logger.info("[Uber Notification] : notifyDriverComming ")
            notifyDriverComming(driver: trip.driver!, vehicle: trip.vehicle!)

        case .arriving:
            Logger.info("[Uber Notification] : notifyDriverAlready ")
            notifyDriverAlready(driver: trip.driver!, vehicle: trip.vehicle!)

        default:
            break
        }
    }

    fileprivate func handleErrorNotification(with error: NSError) {

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
