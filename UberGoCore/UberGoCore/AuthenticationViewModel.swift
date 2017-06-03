//
//  AuthenticationViewModel.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/1/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import OAuthSwift

// MARK: - Protocol
public protocol AuthenticationViewModelProtocol {

    var input: AuthenticationViewModelInput { get }
    var output: AuthenticationViewModelOutput { get }
}

public protocol AuthenticationViewModelInput {

    var loginBtnOnTabPublish: PublishSubject<Void> { get }
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
    fileprivate lazy var oauthUber: OAuth2Swift = self.lazyOauthUber()

    // MARK: - Input
    public var loginBtnOnTabPublish = PublishSubject<Void>()

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
        self.loginBtnOnTabPublish.flatMapLatest { _ -> Observable<OAuthSwiftCredential> in
            return self.loginObserable()
        }
        .do(onNext: { (credential) in
            print(credential)
        })
        .subscribe()
        .addDisposableTo(self.disposeBag)
    }

    fileprivate func lazyOauthUber() -> OAuth2Swift {
        let oauthswift = OAuth2Swift(
            consumerKey:    "fwjlEcQ945pan5s4rYLPzaVhcrbuFPHB",
            consumerSecret: "nyViKGlehMn89Wdu0UFJN_flPKi601T4_CHnude8",
            authorizeUrl:   "https://login.uber.com/oauth/v2/authorize",
            accessTokenUrl: "https://login.uber.com/oauth/v2/token",
            responseType:   "code"
        )
        return oauthswift
    }

    fileprivate func loginObserable() -> Observable<OAuthSwiftCredential> {
        return Observable<OAuthSwiftCredential>.create { (observer) -> Disposable in

            let _ = self.oauthUber.authorize(
                withCallbackURL: URL(string: "oauth-swift://oauth-callback/uber")!,
                scope: "", state:"UBER",
                success: { credential, response, parameters in
                    print(credential.oauthToken)
                    observer.onNext(credential)
            },
                failure: { error in
                    print(error.localizedDescription)
                    observer.onError(error)
            })

            observer.onCompleted()
            return Disposables.create()
        }

    }
}
