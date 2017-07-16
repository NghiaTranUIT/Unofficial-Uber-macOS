//
//  UserObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/2/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa
import OAuthSwift
import Unbox
import RxSwift

open class UserObj: NSObject, NSCoding {

    // MARK: - Variable
    public var name: String?
    public let authToken: AuthToken

    // MARK: - Observer
    public let reloadUberDataPublisher = PublishSubject<Void>()
    public let paymentMethodObjVar = Variable<PaymentObj?>(nil)
    public var selectedNewPaymentObjVar = Variable<PaymentAccountObj?>(nil)
    public var currentPaymentAccountObjVar = Variable<PaymentAccountObj?>(nil)
    fileprivate let disposeBag = DisposeBag()

    // MARK: - Init
    public init(authToken: AuthToken) {
        self.authToken = authToken
        super.init()
        binding()
    }

    public required init(unboxer: Unboxer) throws {
        name = unboxer.unbox(key: Constants.Object.User.Name)
        authToken = AuthToken(token: try unboxer.unbox(key: "token"),
                              refreshToken: try unboxer.unbox(key: "refreshToken"),
                              tokenSecret: try unboxer.unbox(key: "tokenSecret"),
                              tokenExpires: nil)
    }

    @objc required public init?(coder aDecoder: NSCoder) {
        authToken = aDecoder.decodeObject(forKey: Constants.Object.User.Auth) as! AuthToken
        name = aDecoder.decodeObject(forKey: Constants.Object.User.Name) as? String
        super.init()
        binding()
    }

    @objc public func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: Constants.Object.User.Name)
        aCoder.encode(authToken, forKey: Constants.Object.User.Auth)
    }

    // MARK: - Binding
    public func binding() {

        // Payment
        reloadUberDataPublisher
            .asObserver()
            .flatMapLatest { _ -> Observable<PaymentObj> in
                return UberService().paymentMethodObserver()
            }
            .do(onNext: { (paymentObj) in
                Logger.info("Curent PaymentMethods count = \(paymentObj.paymentAccountObjs.count)")
            })
            .bind(to: paymentMethodObjVar)
            .addDisposableTo(disposeBag)

        // Last User or select
        let lastUsed = paymentMethodObjVar.asObservable()
            .filterNil()
            .flatMapLatest({ (paymentObj) -> Observable<PaymentAccountObj> in
                guard let lastUser = paymentObj.lastUsedPaymentAccount else {
                    return Observable.empty()
                }
                return Observable.just(lastUser)
            })

        let newSelectAccount = selectedNewPaymentObjVar
            .asObservable()
            .filterNil()

        // Combine
        Observable.merge([lastUsed, newSelectAccount])
        .bind(to: currentPaymentAccountObjVar)
        .addDisposableTo(disposeBag)
    }

    //TODO: Don't use UserDefault
    // Should try CoreData or Realm instead
    public func historyPlace() -> [PlaceObj] {
        let userDefault = UserDefaults.standard
        guard let data = userDefault.data(forKey: "history") else {
            return []
        }

        guard let histories = NSKeyedUnarchiver.unarchiveObject(with: data) as? [PlaceObj] else {
            return []
        }

        return histories
    }

    public func saveHistoryPlace(_ place: PlaceObj) {
        var histories = historyPlace()

        // Remove
        if let index = histories.index(where: { $0 == place }) {
            histories.remove(at: index)
        }

        // Append at top
        histories.insert(place, at: 0)

        // Save
        let data = NSKeyedArchiver.archivedData(withRootObject: histories)
        let userDefault = UserDefaults.standard
        userDefault.set(data, forKey: "history")
        userDefault.synchronize()
    }
}
