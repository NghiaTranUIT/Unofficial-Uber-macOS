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
open class AuthenticationViewModel: AuthenticationViewModelProtocol,
                                    AuthenticationViewModelInput,
                                    AuthenticationViewModelOutput {

    // MARK: - Protocol
    public var input: AuthenticationViewModelInput { return self }
    public var output: AuthenticationViewModelOutput { return self }

    // MARK: - Variable
    fileprivate let uberOauth: UberOauth
    fileprivate let disposeBag = DisposeBag()
    
    // MARK: - Input
    public var loginBtnOnTabPublish = PublishSubject<Void>()
    public var uberCallbackPublish = PublishSubject<NSAppleEventDescriptor>()

    // MARK: - Output
    public var authenticateStateDriver: Driver<AuthenticationState>!

    // MARK: - Init
    public init(uberOauth: UberOauth) {
        self.uberOauth = uberOauth

        // Check authentication
        let authenticationChanged = Observable<AuthenticationState>
            .create({ (observer) -> Disposable in
                guard let currentUser = UserObj.currentUser else {
                    observer.onNext(.unAuthenticated)
                    return Disposables.create()
                }
                observer.onNext(currentUser.authenticateState)
                return Disposables.create()
        })

        // Login
        let loginSuccess = self.loginBtnOnTabPublish
            .asObserver()
            .flatMapLatest { _ -> Observable<OAuthSwiftCredential?> in
                return uberOauth.oauthUberObserable()
            }
            .do(onNext: { (credential) in
                guard let credential = credential else { return }
                UserObj.convertCurrentUser(with: credential)
            })
            .map({ (credential) -> AuthenticationState in

                guard credential != nil else {
                    return .unAuthenticated
                }

                return .authenticated
            })

        // Merge
        self.authenticateStateDriver = Observable.merge([authenticationChanged, loginSuccess])
            .asDriver(onErrorJustReturn: AuthenticationState.unAuthenticated)

        // Oauth Callback
        self.uberCallbackPublish.bind(to: self.uberOauth.callbackObserverPublish)
        .addDisposableTo(self.disposeBag)
    }
}
