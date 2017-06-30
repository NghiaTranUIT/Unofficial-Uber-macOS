//
//  UserObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/2/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa
import OAuthSwift
import ObjectMapper
import RxSwift

open class UserObj: BaseObj {

    // MARK: - Variable
    public var name: String?
    public let authToken: AuthToken

    // MARK: - Observer
    public let reloadUberDataPublisher = PublishSubject<Void>()
    public let paymentMethodObjVar = Variable<PaymentObj?>(nil)
    public var selectedNewPaymentObjVar = Variable<PaymentAccountObj?>(nil)
    public var currentPaymentAccountObjVar = Variable<PaymentAccountObj?>(nil)

    // MARK: - Init
    public init(authToken: AuthToken) {
        self.authToken = authToken
        super.init()
    }

    override public func mapping(map: Map) {
        super.mapping(map: map)

        self.name <- map[Constants.Object.User.Name]
    }

    required public init?(coder aDecoder: NSCoder) {
        self.authToken = aDecoder.decodeObject(forKey: Constants.Object.User.Auth) as! AuthToken
        super.init(coder: aDecoder)
        self.name = aDecoder.decodeObject(forKey: Constants.Object.User.Name) as? String
    }
    
    public required init?(map: Map) {
        fatalError("init(map:) has not been implemented")
    }

    override public func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(self.name, forKey: Constants.Object.User.Name)
        aCoder.encode(self.authToken, forKey: Constants.Object.User.Auth)
    }

    // MARK: - Binding
    public func binding() {

        // Payment
        self.reloadUberDataPublisher
            .asObserver()
            .flatMapLatest { _ -> Observable<PaymentObj> in
                return UberService().paymentMethodObserver()
            }
            .do(onNext: { (paymentObj) in
                Logger.info("Curent PaymentMethods count = \(paymentObj.paymentAccountObjs?.count ?? 0 )")
            })
            .bind(to: self.paymentMethodObjVar)
            .addDisposableTo(self.disposeBag)

        // Last User or select
        let lastUsed = self.paymentMethodObjVar.asObservable()
            .filterNil()
            .flatMapLatest({ (paymentObj) -> Observable<PaymentAccountObj> in
                guard let lastUser = paymentObj.lastUsedPaymentAccount else {
                    return Observable.empty()
                }
                return Observable.just(lastUser)
            })

        let newSelectAccount = self.selectedNewPaymentObjVar
            .asObservable()
            .filterNil()

        // Combine
        Observable.merge([lastUsed, newSelectAccount])
        .bind(to: self.currentPaymentAccountObjVar)
        .addDisposableTo(self.disposeBag)
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
        var histories = self.historyPlace()

        if histories.contains(place) == false {
            histories.insert(place, at: 0)
        }

        // Save
        let data = NSKeyedArchiver.archivedData(withRootObject: histories)
        let userDefault = UserDefaults.standard
        userDefault.set(data, forKey: "history")
        userDefault.synchronize()
    }
}
