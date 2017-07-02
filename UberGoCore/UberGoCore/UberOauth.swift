//
//  UberAuth.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/3/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation
import OAuthSwift
import RxSwift

open class UberAuth {

    // MARK: - Variable
    public var callbackObserverPublish = PublishSubject<NSAppleEventDescriptor>()
    fileprivate lazy var _oauthUber: OAuth2Swift = self.lazyOauthUber()
    fileprivate let disposeBag = DisposeBag()

    // MARK: - Share
    public static let share = UberAuth()

    // MARK: - Persistant Store
    fileprivate let persistantStore = UserDefaults.standard
    fileprivate static let PersistantStoreKey = "Uber.CurrentUser"

    // MARK: - Current User
    public fileprivate(set) var currentUser: UserObj? {
        didSet {
            if let currentUser = currentUser {

                // Lock
                storeLock.lock()
                defer {
                    self.storeLock.unlock()
                }

                let data = NSKeyedArchiver.archivedData(withRootObject: currentUser)
                persistantStore.set(data, forKey: UberAuth.PersistantStoreKey)
                persistantStore.synchronize()
            } else {

                // Lock
                storeLock.lock()
                defer {
                    self.storeLock.unlock()
                }

                // Remove
                persistantStore.removeObject(forKey: UberAuth.PersistantStoreKey)
                persistantStore.synchronize()
            }
        }
    }
    public var authenState: AuthenticationState {
        if currentUser == nil {
            return .unAuthenticated
        }
        return .authenticated
    }
    fileprivate let lock = NSLock()
    fileprivate let storeLock = NSLock()

    // MARK: - Init
    public init() {

        // Load disk
        self.loadPersistantUser()

        self.callbackObserverPublish
            .subscribe(onNext: { (event) in
                if let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue,
                    let url = URL(string: urlString) {
                    UberAuth.applicationHandle(url: url)
                }
            })
            .addDisposableTo(self.disposeBag)
    }

    // MARK: - Public
    public func authWithUberServiceObserable() -> Observable<AuthenticationState> {
        return self.requestOauthWithUber()
            .do(onNext: {[unowned self] (credential) in
                guard let credential = credential else { return }

                // Convert to user
                self.convertToCurrentUser(credential)
            })
            .map({ $0 != nil ? AuthenticationState.authenticated :
                AuthenticationState.unAuthenticated })
    }

    public func logout() {

        // Lock
        lock.lock()
        defer {
            self.lock.unlock()
        }

        self.currentUser = nil
    }

    fileprivate class func applicationHandle(url: URL) {
        if url.host == "oauth-callback" {
            OAuthSwift.handle(url: url)
        }
        OAuthSwift.handle(url: url)
    }
}

// MARK: - Private
extension UberAuth {

    fileprivate func lazyOauthUber() -> OAuth2Swift {
        return OAuth2Swift(
            consumerKey:    Constants.UberApp.ClientID,
            consumerSecret: Constants.UberApp.SecretID,
            authorizeUrl:   Constants.UberApp.AuthorizeUrl,
            accessTokenUrl: Constants.UberApp.AccessTokenUrl,
            responseType:   Constants.UberApp.ResponseType
        )
    }

    fileprivate func requestOauthWithUber() -> Observable<OAuthSwiftCredential?> {
        return Observable<OAuthSwiftCredential?>.create {[unowned self] (observer) -> Disposable in
            _ = self._oauthUber.authorize (
                withCallbackURL: URL(string: Constants.UberApp.CallBackUrl)!,
                scope: "",
                state: "UBER",
                success: { credential, _, _ in
                    print(credential.oauthToken)
                    observer.onNext(credential)
                    observer.onCompleted()
            },
                failure: { error in
                    print(error.localizedDescription)
                    observer.onNext(nil)
                    observer.onCompleted()
            })

            return Disposables.create()
        }
    }
}

// MARK: - Authentication
extension UberAuth {

    fileprivate func loadPersistantUser() {

        // Lock
        lock.lock()
        defer {
            self.lock.unlock()
        }

        guard let data = UserDefaults.standard.data(forKey: UberAuth.PersistantStoreKey) else { return }
        guard let userObj = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserObj else { return }
        self.currentUser = userObj
    }

    public func convertToCurrentUser(_ credential: OAuthSwiftCredential) {

        // Lock
        lock.lock()
        defer {
            self.lock.unlock()
        }

        let token = AuthToken(credential: credential)
        let user = UserObj(authToken: token)
        self.currentUser = user
    }
}
