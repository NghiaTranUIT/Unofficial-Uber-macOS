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
}

public protocol AuthenticationViewModelOutput {

    var authenticateStateDriver: Driver<AuthenticationState> { get }
}

// MARK: - View Model
open class AuthenticationViewModel: AuthenticationViewModelProtocol,
                                    AuthenticationViewModelInput,
                                    AuthenticationViewModelOutput {

    // MARK: - Protocol
    public var input: AuthenticationViewModelInput { return self }
    public var output: AuthenticationViewModelOutput { return self }

    // MARK: - Variable
    fileprivate let uberOauth = UberAuth.share

    // MARK: - Input
    public var loginBtnOnTabPublish = PublishSubject<Void>()

    // MARK: - Output
    public var authenticateStateDriver: Driver<AuthenticationState>

    // MARK: - Init
    public init() {

        // Check authentication
        let authenticationChanged = UberAuth.share.authenStateObj

        // Login
        let loginSuccess = loginBtnOnTabPublish
            .asObserver()
            .flatMapLatest { _ -> Observable<AuthenticationState> in
                return UberAuth.share.authWithUberServiceObserable()
            }

        // Merge
        authenticateStateDriver = Observable.merge([authenticationChanged, loginSuccess])
            .do(onNext: { (state) in
                Logger.info(state)
            })
            .asDriver(onErrorJustReturn: AuthenticationState.unAuthenticated)
    }
}
