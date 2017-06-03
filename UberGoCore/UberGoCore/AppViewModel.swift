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
    public var switchPopoverPublish = PublishSubject<Void>()
    public var popoverStateVariable = Variable<PopoverState>(.close)

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
    }
}
