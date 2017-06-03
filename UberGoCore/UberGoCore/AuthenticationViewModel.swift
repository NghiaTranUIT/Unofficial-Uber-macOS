//
//  AuthenticationViewModel.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/1/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation
import RxSwift

// MARK: - Protocol
public protocol AuthenticationViewModelProtocol {

    var input: AuthenticationViewModelInput { get }
    var output: AuthenticationViewModelOutput { get }
}

public protocol AuthenticationViewModelInput {

}

public protocol AuthenticationViewModelOutput {

    var authenticateStateObserver: Observable<AuthenticationState> { get }
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

    // MARK: - Input

    // MARK: - Output
    public var authenticateStateObserver: Observable<AuthenticationState>

    // MARK: - Init
    override init() {

        // Check authentication
        self.authenticateStateObserver = Observable<AuthenticationState>.create({ (observer) -> Disposable in

            guard let currentUser = UserObj.currentUser else {
                observer.onNext(.unAuthenticated)
                return Disposables.create()
            }

            observer.onNext(currentUser.authenticateState)
            return Disposables.create()
        })

    }
}
