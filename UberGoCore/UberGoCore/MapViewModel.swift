//
//  MapViewModel.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/3/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation
import MapKit
import RxCocoa
import RxSwift

// MARK: - Protocol
public protocol MapViewModelProtocol {

    var input: MapViewModelInput { get }
    var output: MapViewModelOutput { get }
}

public protocol MapViewModelInput {

    var startUpdateLocationTriggerPublisher: PublishSubject<Bool> { get }
    var textSearchPublish: PublishSubject<String> { get }
}

public protocol MapViewModelOutput {

    var currentLocationDriver: Driver<CLLocation?> { get }
    var nearestPlaceDriver: Driver<PlaceObj> { get }
    var productsVariable: Variable<[ProductObj]> { get }
    var searchPlaceObjsVariable: Variable<[PlaceObj]> { get }
    var personPlaceObjsVariable: Variable<[PlaceObj]> { get }
    var loadingPublisher: PublishSubject<Bool> { get }
}

// MARK: - View Model
open class MapViewModel: BaseViewModel,
                        MapViewModelProtocol,
                        MapViewModelInput,
                        MapViewModelOutput {

    // MARK: - Protocol
    public var input: MapViewModelInput { return self }
    public var output: MapViewModelOutput { return self }

    // MARK: - Variable
    fileprivate let mapManager = MapService()
    fileprivate let uberService = UberService()

    // MARK: - Input
    public var startUpdateLocationTriggerPublisher = PublishSubject<Bool>()
    public var textSearchPublish = PublishSubject<String>()

    // MARK: - Output
    public var currentLocationDriver: Driver<CLLocation?> {
        return mapManager.currentLocationVariable.asDriver()
    }
    public var productsVariable = Variable<[ProductObj]>([])
    public var nearestPlaceDriver: Driver<PlaceObj> {
        return self.mapManager.nearestPlaceObverser.asDriver(onErrorJustReturn: PlaceObj.unknowPlace)
    }
    public var searchPlaceObjsVariable = Variable<[PlaceObj]>([])
    public var personPlaceObjsVariable = Variable<[PlaceObj]>([])
    public var loadingPublisher = PublishSubject<Bool>()

    // MARK: - Init
    public override init() {
        super.init()

        // Start update location
        self.startUpdateLocationTriggerPublisher
            .asObserver()
            .distinctUntilChanged()
            .subscribe(onNext: {[unowned self] (trigger) in
                if trigger {
                    self.mapManager.startUpdatingLocation()
                } else {
                    self.mapManager.stopUpdatingLocation()
                }
            })
            .addDisposableTo(self.disposeBag)

        let shared = self.textSearchPublish
            .asObservable()
            .share()

        let searchTextObserver = shared
            .asObservable()
            .debounce(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .flatMapLatest {[unowned self] (text) -> Observable<[PlaceObj]> in
                guard let currentCoordinate = self.mapManager.currentLocationVariable.value?.coordinate else {
                    return Observable.empty()
                }

                if text == "" {
                    return Observable.empty()
                }

                // Start
                self.loadingPublisher.onNext(true)

                // Search
                let param = PlaceSearchRequestParam(keyword: text, location: currentCoordinate)
                return PlaceSearchRequest(param).toObservable()
            }

        let personalObserver = shared
            .distinctUntilChanged()
            .flatMapLatest { (text) -> Observable<[PlaceObj]> in
                guard text == "" else {
                    return Observable.empty()
                }

                // Start
                self.loadingPublisher.onNext(true)

                return self.personPlaceObjsVariable.asObservable()
            }

        Observable.merge([searchTextObserver, personalObserver])
            .skip(1)
            .do(onNext: {[weak self] _ in
                guard let `self` = self else { return }
                self.loadingPublisher.onNext(false)
            })
            .bind(to: self.searchPlaceObjsVariable)
            .addDisposableTo(self.disposeBag)

        // Person place
        self.loadingPublisher.onNext(true)
        self.uberService
            .personalPlaceObserver()
            // Map in map: [UberPersonalPlaceObj] -> [PlaceObj]
            .map({ $0.map({ PlaceObj(personalPlaceObj: $0) }) })
            .bind(to: self.personPlaceObjsVariable)
            .addDisposableTo(self.disposeBag)
    }
}
