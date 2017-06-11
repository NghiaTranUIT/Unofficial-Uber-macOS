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
    fileprivate var mapManager = MapService()

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

    // MARK: - Init
    public override init() {
        super.init()

        // Start update
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
//        self.textSearchPublish.asObserver()
//            .throttle(0.3, scheduler: MainScheduler.instance)
//            .distinctUntilChanged()
//            .flatMapLatest { text -> Observable<[PlaceObj]> in
//
//                let param = PlaceSearchRequestParam(keyword: text, location: <#T##CLLocationCoordinate2D#>)
//        }
    }
}
