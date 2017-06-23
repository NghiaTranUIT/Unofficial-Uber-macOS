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
}

public protocol AppViewModelOutput {

    var popoverStateVariable: Variable<PopoverState> { get }
}

// MARK: - App ViewModel
open class AppViewModel: BaseViewModel, AppViewModelProtocol, AppViewModelInput, AppViewModelOutput {

    // MARK: - View model
    public var input: AppViewModelInput { return self }
    public var output: AppViewModelOutput { return self }

    // MARK: - Variable
    public var actionPopoverPublish = PublishSubject<PopoverState>()
    public var switchPopoverPublish = PublishSubject<Void>()
    public var popoverStateVariable = Variable<PopoverState>(.close)

    public var currentTripStatusPublish = PublishSubject<Void>()
    public var cancelCurrentTripPublish = PublishSubject<Void>()

    fileprivate let uberService = UberService()

    // MARK: - Init
    public override init() {
        super.init()
        // Switch
        self.switchPopoverPublish.map {[weak self] _ -> PopoverState in
            guard let `self` = self else { return .open }

            if self.popoverStateVariable.value == .open {
                return .close
            }
            return .open
        }.bind(to: popoverStateVariable)
        .addDisposableTo(self.disposeBag)

        self.actionPopoverPublish.bind(to: self.popoverStateVariable)
        .addDisposableTo(self.disposeBag)

        // Debug
        self.currentTripStatusPublish.asObserver()
        .flatMapLatest {[unowned self] _ -> Observable<TripObj> in
            return self.uberService.getCurrentTrip()
        }
        .subscribe(onNext: { (tripObj) in
            Logger.info("[DEBUG] CURRENT TRIP = \(tripObj)")
        })
        .addDisposableTo(self.disposeBag)

        self.cancelCurrentTripPublish.asObserver()
        .flatMapLatest {[unowned self] (_) -> Observable<Void> in
            return self.uberService.cancelCurrentTrip()
        }
        .subscribe(onNext: { _ in
            Logger.info("[DEBUG] CANCEL TRIP OK")
        })
        .addDisposableTo(self.disposeBag)
    }
}
