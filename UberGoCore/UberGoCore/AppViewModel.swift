//
//  AppViewModel.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/1/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public enum PopoverState {
    case open
    case close
}

// MARK: - Protocol 
public protocol AppViewModelProtocol {

    var input: AppViewModelInput { get }
    var output: AppViewModelOutput { get }
}

public protocol AppViewModelInput {

    var switchPopoverPublish: PublishSubject<Void> { get }
    var actionPopoverPublish: PublishSubject<PopoverState> { get }

    // Debug
    var currentTripStatusPublish: PublishSubject<Void> { get }
    var cancelCurrentTripPublish: PublishSubject<Void> { get }
    var updateStatusTripPublish: PublishSubject<TripObjStatus> { get }
}

public protocol AppViewModelOutput {

    var popoverStateVariable: Variable<PopoverState> { get }
}

// MARK: - App ViewModel
open class AppViewModel: AppViewModelProtocol,
                         AppViewModelInput,
                         AppViewModelOutput {

    // MARK: - View model
    public var input: AppViewModelInput { return self }
    public var output: AppViewModelOutput { return self }

    // MARK: - Variable
    public var actionPopoverPublish = PublishSubject<PopoverState>()
    public var switchPopoverPublish = PublishSubject<Void>()
    public var popoverStateVariable = Variable<PopoverState>(.close)

    public var currentTripStatusPublish = PublishSubject<Void>()
    public var cancelCurrentTripPublish = PublishSubject<Void>()
    public var updateStatusTripPublish = PublishSubject<TripObjStatus>()
    fileprivate var sandboxStatus = TripObjStatus.unknown

    fileprivate let uberService: UberService
    fileprivate let disposeBag = DisposeBag()

    // MARK: - Init
    public init(uberService: UberService) {

        self.uberService = uberService

        // Switch
        switchPopoverPublish
            .withLatestFrom(popoverStateVariable.asObservable())
            .map({ return $0 == .open ? .close : .open })
            .bind(to: popoverStateVariable)
            .addDisposableTo(disposeBag)

        // Map
        actionPopoverPublish
            .bind(to: popoverStateVariable)
            .addDisposableTo(disposeBag)

        // Debug Current Trip
        currentTripStatusPublish
            .flatMapLatest { uberService.getCurrentTrip() }
            .subscribe(onNext: { (tripObj) in
                Logger.info("[DEBUG] CURRENT TRIP = \(tripObj)")
            })
            .addDisposableTo(disposeBag)

        // Debug Cancel
        cancelCurrentTripPublish
            .flatMapLatest { uberService.cancelCurrentTrip() }
            .subscribe(onNext: { _ in
                Logger.info("[DEBUG] CANCEL TRIP OK")
            })
            .addDisposableTo(disposeBag)

        // Debug Update status
        updateStatusTripPublish
            .do(onNext: {[unowned self] (status) in
                self.sandboxStatus = status
            })
            .flatMapLatest({ _ -> Observable<TripObj> in
                return uberService.getCurrentTrip()
            })
            .flatMapLatest {[unowned self] (tripObj) -> Observable<Void> in
                let requestID = tripObj.requestId
                return SandboxUberService().updateTripStateObserver(status: self.sandboxStatus, requestID: requestID)
            }
            .subscribe(onNext: {[unowned self] _ in
                Logger.info("[DEBUG] UPDATE TRIP = \(self.sandboxStatus.rawValue)")
            })
            .addDisposableTo(disposeBag)

        // Notification
        NotificationCenter.observeNotificationType(.showPopover,
                                                   observer: self,
                                                   selector: #selector(self.showPopoverNotification),
                                                   object: nil)
    }

    deinit {
        NotificationCenter.removeAllObserve(self)
    }

    @objc func showPopoverNotification() {
        actionPopoverPublish.onNext(.open)
    }
}
