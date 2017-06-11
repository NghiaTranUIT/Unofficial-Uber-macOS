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
    var personPlaceVariable: Variable<[UberPersonalPlaceObj]> { get }
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
    public var personPlaceVariable = Variable<[UberPersonalPlaceObj]>([])

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

        // Search
        self.textSearchPublish.asObserver()
            .skip(1)
            .debounce(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .flatMapLatest { text -> Observable<[PlaceObj]> in

                guard let currentCoordinate = self.mapManager.currentLocationVariable.value?.coordinate else {
                    return Observable.empty()
                }

                if text == "" {
                    return Observable.just([])
                }

                // Search
                let param = PlaceSearchRequestParam(keyword: text, location: currentCoordinate)
                return PlaceSearchRequest(param).toObservable()
            }
            .bind(to: self.searchPlaceObjsVariable)
            .addDisposableTo(self.disposeBag)

        // Person place
        self.uberService.personalPlaceObserver()
            .bind(to: self.personPlaceVariable)
            .addDisposableTo(self.disposeBag)
    }
}
