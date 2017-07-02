//
//  AuthenticationViewModel.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/1/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation
import OAuthSwift
import RxCocoa
import RxSwift

// MARK: - Protocol
public protocol AuthenticationViewModelProtocol {

    var input: AuthenticationViewModelInput { get }
    var output: AuthenticationViewModelOutput { get }
}

public protocol AuthenticationViewModelInput {

    var loginBtnOnTabPublish: PublishSubject<Void> { get }
    var uberCallbackPublish: PublishSubject<NSAppleEventDescriptor> { get }
}

public protocol AuthenticationViewModelOutput {

    var authenticateStateDriver: Driver<AuthenticationState>! { get }
}

// MARK: - View Model
open class AuthenticationViewModel: BaseViewModel,
    AuthenticationViewModelProtocol,
    AuthenticationViewModelInput,
AuthenticationViewModelOutput {

    // MARK: - Protocol
    public var input: AuthenticationViewModelInput { return self }
    public var output: AuthenticationViewModelOutput { return self }

    // MARK: - Variable
    fileprivate let uberOauth = UberAuth.share

    // MARK: - Input
    public var loginBtnOnTabPublish = PublishSubject<Void>()
    public var uberCallbackPublish = PublishSubject<NSAppleEventDescriptor>()

    // MARK: - Output
    public var authenticateStateDriver: Driver<AuthenticationState>!

    // MARK: - Init
    public override init() {
        super.init()

        // Check authentication
        let authenticationChanged = Observable<AuthenticationState>
            .create({ (observer) -> Disposable in
                guard UberAuth.share.currentUser != nil else {
                    observer.onNext(.unAuthenticated)
                    return Disposables.create()
                }

                observer.onNext(.authenticated)
                return Disposables.create()
            })

        // Login
        let loginSuccess = self.loginBtnOnTabPublish
            .asObserver()
            .flatMapLatest {[unowned self] _ -> Observable<AuthenticationState> in
                return self.uberOauth.authWithUberServiceObserable()
            }

        // Merge
        self.authenticateStateDriver = Observable.merge([authenticationChanged, loginSuccess])
            .asDriver(onErrorJustReturn: AuthenticationState.unAuthenticated)

        // Oauth Callback
        self.uberCallbackPublish.bind(to: self.uberOauth.callbackObserverPublish)
            .addDisposableTo(self.disposeBag)
    }
}
