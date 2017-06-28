//
//  MapViewModel.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/3/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation
import MapboxDirections
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
    var didSelectPlaceObjPublisher: PublishSubject<PlaceObj?> { get }
    var routeForCurrentTripPublisher: PublishSubject<TripObj> { get }
}

public protocol MapViewModelOutput {

    // Origin
    var currentLocationDriver: Driver<CLLocation?> { get }
    var nearestPlaceDriver: Driver<PlaceObj> { get }

    // Search
    var searchPlaceObjsVariable: Variable<[PlaceObj]> { get }
    var loadingDriver: Driver<Bool> { get }

    // Destination
    var selectedPlaceObjDriver: Driver<PlaceObj?> { get }
    var selectedDirectionRouteObserver: Observable<Route?> { get }
    var isSelectedPlace: Driver<Bool> { get }

    // Route
    var routeCurrentTrip: Driver<Route?> { get }
}

// MARK: - View Model
open class MapViewModel:
                        MapViewModelProtocol,
                        MapViewModelInput,
                        MapViewModelOutput {

    public let disposeBag = DisposeBag()

    // MARK: - Protocol
    public var input: MapViewModelInput { return self }
    public var output: MapViewModelOutput { return self }

    // MARK: - Variable
    fileprivate let mapManager: MapService
    fileprivate let uberService: UberService
    fileprivate let directionService: DirectionService

    // MARK: - Input
    public var startUpdateLocationTriggerPublisher = PublishSubject<Bool>()
    public var textSearchPublish = PublishSubject<String>()
    public var didSelectPlaceObjPublisher = PublishSubject<PlaceObj?>()
    public var routeForCurrentTripPublisher = PublishSubject<TripObj>()

    // MARK: - Output
    public var currentLocationVariable: Variable<CLLocation?> {
        return mapManager.currentLocationVariable
    }
    public var currentLocationDriver: Driver<CLLocation?> {
        return mapManager.currentLocationVariable.asDriver()
    }
    public var nearestPlaceDriver: Driver<PlaceObj> {
        return self.mapManager.nearestPlaceObverser.asDriver(onErrorJustReturn: PlaceObj.unknowPlace)
    }
    public var searchPlaceObjsVariable = Variable<[PlaceObj]>([])
    fileprivate var personalOrHistoryPlaceObjsVariable = Variable<[PlaceObj]>([])
    public let loadingDriver: Driver<Bool>
    public var selectedPlaceObjDriver: Driver<PlaceObj?>
    public var selectedDirectionRouteObserver: Observable<Route?>
    public var isSelectedPlace: Driver<Bool> {
        return self.selectedPlaceObjDriver.map({ $0 != nil })
    }
    public var routeCurrentTrip: Driver<Route?>

    // MARK: - Init
    public init(mapManager: MapService = MapService(),
                uberService: UberService = UberService(),
                directionService: DirectionService = DirectionService()) {

        self.mapManager = mapManager
        self.uberService = uberService
        self.directionService = directionService

        // Start update location
        self.startUpdateLocationTriggerPublisher
            .asObserver()
            .distinctUntilChanged()
            .subscribe(onNext: {(trigger) in
                if trigger {
                    mapManager.startUpdatingLocation()
                } else {
                    mapManager.stopUpdatingLocation()
                }
            })
            .addDisposableTo(self.disposeBag)

        // Load personal or history place
        let personalPlace = self.uberService
            .personalPlaceObserver()
            .startWith([]) // Don't need to wait -> Should show history palce first
            // Map in map: [UberPersonalPlaceObj] -> [PlaceObj]
            .map({ $0.map({ PlaceObj(personalPlaceObj: $0) }) })

        let historyPlace = self.uberService.historyObserver

        Observable.combineLatest([personalPlace, historyPlace])
        .map { (combine) -> [PlaceObj] in
            let personPlaces = combine.first!
            let historyPlaces = combine.last!
            return personPlaces + historyPlaces
        }.bind(to: self.personalOrHistoryPlaceObjsVariable)
        .addDisposableTo(self.disposeBag)

        // Trigger
        self.uberService.reloadHistoryTrigger.onNext()

        // Text Search
        let shared = self.textSearchPublish
            .asObservable()
            .share()

        // Reset Empty data while fetching
        let emptyOb = shared
            .filter({ $0 != "" })
            .map { _ -> [PlaceObj] in
                return []
            }

        // Search from Google Service
        let searchPlaceOb = shared
            .filter { $0 != "" }
            .debounce(0.3, scheduler: MainScheduler.instance)
            .filter { $0 != "" }
            .distinctUntilChanged()
            .flatMapLatest {(text) -> Observable<[PlaceObj]> in
                guard let currentCoordinate = mapManager.currentLocationVariable.value?.coordinate else {
                    return Observable.empty()
                }

                // Search
                let param = PlaceSearchRequestParam(keyword: text, location: currentCoordinate)
                return PlaceSearchRequest(param).toObservable()
            }
            .share()

        let personalOrHistoryOb = shared
            .distinctUntilChanged()
            .filter({ $0 == "" })
            .withLatestFrom(self.personalOrHistoryPlaceObjsVariable.asObservable())
            .share()

        // Merage into searchPlace
        let searchFinishOb = Observable.merge([searchPlaceOb,
                          personalOrHistoryOb,
                          emptyOb,
                          self.personalOrHistoryPlaceObjsVariable.asObservable()])
            .skip(1)
            .share()

        searchFinishOb
            .bind(to: self.searchPlaceObjsVariable)
            .addDisposableTo(self.disposeBag)

        // Loader
        let startLoadingOb = Observable.merge([searchPlaceOb, personalOrHistoryOb]).map { _ in true }
        let stopLoadingOb = searchFinishOb.map { _ in false }
        self.loadingDriver = Observable.merge([startLoadingOb, stopLoadingOb])
            .map({ !$0 })
            .asDriver(onErrorJustReturn: false)

        // Selected
        let selectedPlaceObserve = self.didSelectPlaceObjPublisher
            .asObserver()
            .share()

        self.selectedPlaceObjDriver = selectedPlaceObserve.asDriver(onErrorJustReturn: nil)
        let clearCurrentDirectionRoute = selectedPlaceObserve.map { _ -> Route? in return nil }
        let getDirection = selectedPlaceObserve
            .flatMapLatest { toPlace -> Observable<Route?> in

                guard let toPlace = toPlace else {
                    return Observable.empty()
                }

                //FIXME : Temporary get current location
                // Should refactor currentLocationVariable
                // is Observable<PlaceObj>
                // PlaceObj maybe work/home or coordinate or googleplace
                let current = mapManager.currentLocationVariable.value!
                let place = PlaceObj()
                place.coordinate2D = current.coordinate
                place.name = "Current location"
                return directionService.generateDirectionRoute(from: place, to: toPlace)
            }
            .observeOn(MainScheduler.instance)

        self.selectedDirectionRouteObserver = Observable.merge([getDirection, clearCurrentDirectionRoute])

        // Save History place
        selectedPlaceObserve.subscribe(onNext: { placeObj in
            guard let placeObj = placeObj else { return }
            guard let currentUser = UserObj.currentUser else { return }

            // Only save normal place to history
            // Don't save personal place
            guard placeObj.placeType == .place else { return }

            // Save history
            currentUser.saveHistoryPlace(placeObj)

            // Load again
            uberService.reloadHistoryTrigger.onNext()
        })
        .addDisposableTo(self.disposeBag)

        // Request Route for Current Trip
        self.routeCurrentTrip = self.routeForCurrentTripPublisher
            .asObserver()
            .flatMapLatest { tripObj -> Observable<Route?> in
                guard let pickup = tripObj.pickup else {
                    return Observable.just(nil)
                }
                guard let driver = tripObj.location else {
                    return Observable.just(nil)
                }

                return directionService.generateDirectionRoute(from: driver.coordinate, originName: "Driver",
                                                                to: pickup.coordinate, destinationName: "Pickup")
            }
        .asDriver(onErrorJustReturn: nil)
    }
}
