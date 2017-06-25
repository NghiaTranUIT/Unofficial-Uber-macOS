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
    fileprivate lazy var uberOauth: UberOauth = {
        return UberOauth()
    }()

    // MARK: - Input
    public var loginBtnOnTabPublish = PublishSubject<Void>()
    public var uberCallbackPublish = PublishSubject<NSAppleEventDescriptor>()

    // MARK: - Output
    public var authenticateStateDriver: Driver<AuthenticationState>!

    // MARK: - Init
    public override init() {
        super.init()

        // Check authentication
        self.authenticateStateDriver = Observable<AuthenticationState>.create({ (observer) -> Disposable in
            guard let currentUser = UserObj.currentUser else {
                observer.onNext(.unAuthenticated)
                return Disposables.create()
            }

            observer.onNext(currentUser.authenticateState)
            return Disposables.create()
        })
        .asDriver(onErrorJustReturn: AuthenticationState.unAuthenticated)

        // Login
        self.loginBtnOnTabPublish
        .flatMapLatest {[unowned self] _ -> Observable<OAuthSwiftCredential> in
            return self.uberOauth.oauthUberObserable()
        }
        .map({ (credential) -> UserObj in
            return UserObj.convertCurrentUser(with: credential)
        })
        .subscribe()
        .addDisposableTo(self.disposeBag)

        // Oauth Callback
        self.uberCallbackPublish.bind(to: self.uberOauth.callbackObserverPublish)
        .addDisposableTo(self.disposeBag)
    }
}
