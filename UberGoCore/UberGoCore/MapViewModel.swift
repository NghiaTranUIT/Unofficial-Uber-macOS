//
//  MapViewModel.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/3/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation
import MapKit
import MapboxDirections
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
    var didSelectPlaceObjPublisher: PublishSubject<PlaceObj?> { get }
}

public protocol MapViewModelOutput {

    // Origin
    var currentLocationDriver: Driver<CLLocation?> { get }
    var nearestPlaceDriver: Driver<PlaceObj> { get }

    // Search
    var searchPlaceObjsVariable: Variable<[PlaceObj]> { get }
    var loadingPublisher: PublishSubject<Bool> { get }

    // Destination
    var selectedPlaceObjDriver: Driver<PlaceObj?>! { get }
    var selectedDirectionRouteObserver: Observable<Route?>! { get }
    var isSelectedPlace: Driver<Bool> { get }
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
    fileprivate let directionService = DirectionService()

    // MARK: - Input
    public var startUpdateLocationTriggerPublisher = PublishSubject<Bool>()
    public var textSearchPublish = PublishSubject<String>()
    public var didSelectPlaceObjPublisher = PublishSubject<PlaceObj?>()

    // MARK: - Output
    public var currentLocationDriver: Driver<CLLocation?> {
        return mapManager.currentLocationVariable.asDriver()
    }
    public var nearestPlaceDriver: Driver<PlaceObj> {
        return self.mapManager.nearestPlaceObverser.asDriver(onErrorJustReturn: PlaceObj.unknowPlace)
    }
    public var searchPlaceObjsVariable = Variable<[PlaceObj]>([])
    fileprivate var personalOrHistoryPlaceObjsVariable = Variable<[PlaceObj]>([])
    public var loadingPublisher = PublishSubject<Bool>()
    public var selectedPlaceObjDriver: Driver<PlaceObj?>!
    public var selectedDirectionRouteObserver: Observable<Route?>!
    public var isSelectedPlace: Driver<Bool> {
        return self.selectedPlaceObjDriver.map({ $0 != nil })
    }

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

        // Load personal or history place
        self.loadingPublisher.onNext(true)
        self.uberService
            .personalPlaceObserver()
            // Map in map: [UberPersonalPlaceObj] -> [PlaceObj]
            .map({ $0.map({ PlaceObj(personalPlaceObj: $0) }) })
            .bind(to: self.personalOrHistoryPlaceObjsVariable)
            .addDisposableTo(self.disposeBag)

        // Text Search
        let shared = self.textSearchPublish
            .asObservable()
            .share()
        let searchPlaceObserver = shared
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
        let personalOrHistoryObserver = shared
            .distinctUntilChanged()
            .flatMapLatest { (text) -> Observable<[PlaceObj]> in
                guard text == "" else {
                    return Observable.empty()
                }

                // Start
                self.loadingPublisher.onNext(true)

                return self.personalOrHistoryPlaceObjsVariable.asObservable()
            }

        // Merage into searchPlace
        Observable.merge([searchPlaceObserver,
                          personalOrHistoryObserver,
                          self.personalOrHistoryPlaceObjsVariable.asObservable()])
            .skip(1)
            .do(onNext: {[weak self] _ in
                guard let `self` = self else { return }
                self.loadingPublisher.onNext(false)
            })
            .bind(to: self.searchPlaceObjsVariable)
            .addDisposableTo(self.disposeBag)

        // Selected
        let selectedPlaceObserve = self.didSelectPlaceObjPublisher
            .asObserver()
            .share()
        self.selectedPlaceObjDriver = selectedPlaceObserve.asDriver(onErrorJustReturn: nil)
        let clearCurrentDirectionRoute = selectedPlaceObserve.map { _ -> Route? in return nil }
        let getDirection = selectedPlaceObserve
            .flatMapLatest {[unowned self] toPlace -> Observable<Route?> in

                guard let toPlace = toPlace else {
                    return Observable.empty()
                }

                //FIXME : Temporary get current location
                // Should refactor currentLocationVariable
                // is Observable<PlaceObj>
                // PlaceObj maybe work/home or coordinate or googleplace
                let current = self.mapManager.currentLocationVariable.value!
                let place = PlaceObj()
                place.coordinate2D = current.coordinate
                place.name = "Current location"
                return self.directionService.generateDirectionRoute(from: place, to: toPlace)
            }
            .observeOn(MainScheduler.instance)

        self.selectedDirectionRouteObserver = Observable.merge([getDirection, clearCurrentDirectionRoute])
    }
}
