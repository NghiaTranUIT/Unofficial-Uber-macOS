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
    var selectPlaceObjPublisher: PublishSubject<PlaceObj?> { get }
    var routeToDestinationPublisher: PublishSubject<PlaceObj> { get }
    var routeForCurrentTripPublisher: PublishSubject<TripObj> { get }
}

public protocol MapViewModelOutput {

    // Origin
    var currentPlaceDriver: Driver<PlaceObj> { get }

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
    fileprivate let mapService: MapService
    fileprivate let uberService: UberService
    fileprivate let directionService: DirectionService

    // MARK: - Input
    public var startUpdateLocationTriggerPublisher = PublishSubject<Bool>()
    public var selectPlaceObjPublisher = PublishSubject<PlaceObj?>()
    public var routeForCurrentTripPublisher = PublishSubject<TripObj>()
    public var routeToDestinationPublisher = PublishSubject<PlaceObj>()

    // MARK: - Output
    public var currentPlaceDriver: Driver<PlaceObj> {
        return mapService.output.currentPlaceObs
            .asDriver(onErrorJustReturn: PlaceObj.invalid)
    }
    public var currentLocationVariable: Variable<CLLocation?> { return mapService.output.currentLocationVar }
    public var selectedPlaceObjDriver: Driver<PlaceObj?>
    public var selectedDirectionRouteObserver: Observable<Route?>
    public var isSelectedPlace: Driver<Bool> { return selectedPlaceObjDriver.map({ $0 != nil }) }
    public var routeCurrentTrip: Driver<Route?>

    // MARK: - Init
    public init(mapService: MapService = MapService.share,
                uberService: UberService = UberService(),
                directionService: DirectionService = DirectionService(),
                googleMapService: GoogleMapService = GoogleMapService()) {

        self.mapService = mapService
        self.uberService = uberService
        self.directionService = directionService

        // Start update location
        startUpdateLocationTriggerPublisher
            .asObserver()
            .distinctUntilChanged()
            .subscribe(onNext: {(trigger) in
                if trigger {
                    mapService.startUpdatingLocation()
                } else {
                    mapService.stopUpdatingLocation()
                }
            })
            .addDisposableTo(disposeBag)

        // Selected
        let selectedPlaceObserve = selectPlaceObjPublisher
            .asObserver()
            .share()

        selectedPlaceObjDriver = selectedPlaceObserve.asDriver(onErrorJustReturn: nil)
        let clearCurrentDirectionRoute = selectedPlaceObserve.map { _ -> Route? in return nil }

        // Get Route
        let currentPlaceObj = routeToDestinationPublisher
            .withLatestFrom(mapService.currentPlaceObs.asObservable())
        let getDirection = Observable.zip([selectedPlaceObserve.filterNil(), currentPlaceObj])
            .flatMapLatest { data -> Observable<Route?> in
                let from = data.first!
                let to = data[1]
                return directionService.generateDirectionRoute(from: from, to: to)
            }
            .observeOn(MainScheduler.instance)

        selectedDirectionRouteObserver = Observable.merge([getDirection, clearCurrentDirectionRoute])

        // Request Route for Current Trip
        routeCurrentTrip = routeForCurrentTripPublisher
            .asObserver()
            .flatMapLatest { tripObj -> Observable<Route?> in
                guard
                    let pickup = tripObj.pickup,
                    let driver = tripObj.location else {
                    return Observable.just(nil)
                }

                return directionService.generateDirectionRoute(from: driver.coordinate, originName: "Driver",
                                                                to: pickup.coordinate, destinationName: "Pickup")
            }
        .asDriver(onErrorJustReturn: nil)
    }
}
