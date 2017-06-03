//
//  UberOauth.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/3/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation
import OAuthSwift
import RxSwift

class UberOauth {

    // MARK: - Variable
    public var callbackObserverPublish = PublishSubject<NSAppleEventDescriptor>()
    fileprivate lazy var oauthUber: OAuth2Swift = self.lazyOauthUber()
    fileprivate let disposeBag = DisposeBag()

    // MARK: - Init
    public init() {

        self.callbackObserverPublish
            .subscribe(onNext: { (event) in
                print("HERE")
                if let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue,
                    let url = URL(string: urlString) {
                    UberOauth.applicationHandle(url: url)
                }
            })
            
            .addDisposableTo(self.disposeBag)
    }

    // MARK: - Public
    public func oauthUberObserable() -> Observable<OAuthSwiftCredential> {

        return Observable<OAuthSwiftCredential>.create { (observer) -> Disposable in
            _ = self.oauthUber.authorize (
                withCallbackURL: URL(string: Constants.UberApp.CallBackUrl)!,
                scope: "", state:"UBER",
                success: { credential, _, _ in
                    print(credential.oauthToken)
                    observer.onNext(credential)
                    observer.onCompleted()
            },
                failure: { error in
                    print(error.localizedDescription)
                    observer.onError(error)
            })

            return Disposables.create()
        }
    }

    fileprivate class func applicationHandle(url: URL) {
        if url.host == "oauth-callback" {
            OAuthSwift.handle(url: url)
        }
        // Google provider is the only one wuth your.bundle.id url schema.
        OAuthSwift.handle(url: url)
    }
}

// MARK: - Private
extension UberOauth {

    fileprivate func lazyOauthUber() -> OAuth2Swift {
        return OAuth2Swift(
            consumerKey:    Constants.UberApp.ClientID,
            consumerSecret: Constants.UberApp.SecretID,
            authorizeUrl:   Constants.UberApp.AuthorizeUrl,
            accessTokenUrl: Constants.UberApp.AccessTokenUrl,
            responseType:   Constants.UberApp.ResponseType
        )
    }
}
