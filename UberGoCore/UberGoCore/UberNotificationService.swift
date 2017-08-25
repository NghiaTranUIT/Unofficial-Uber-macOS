//
//  UberNotificationService.swift
//  UberGoCore
//
//  Created by Nghia Tran on 8/23/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation

class UberNotificationService {

    // MARK: - Variable
    fileprivate let _service: UserNotificationServiceProtocol

    // MARK: - Init
    init(service: UserNotificationServiceProtocol) {
        _service = service
    }

    // MARK: - Public
    func notifyDriverComming(driver: DriverObj, vehicle: VehicleObj) {
        let action = DriverCommingAction(driver: driver, vehicle: vehicle)
        _service.publishAction(action)
    }

    func notifyDriverAlready(driver: DriverObj, vehicle: VehicleObj) {
        let action = DriverAlreadyAction(driver: driver, vehicle: vehicle)
        _service.publishAction(action)
    }

    func notifyTripSuccessful(receipt: ReceiptObj) {
        let action = TripSuccessfulAction(receipt: receipt)
        _service.publishAction(action)
    }

    func notifyCancelTrip() {
        let action = CancelTripAction()
        _service.publishAction(action)
    }
}

// MARK: - Private
extension UberNotificationService {

}
