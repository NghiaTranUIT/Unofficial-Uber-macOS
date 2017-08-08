//
//  SearchBarViewModel.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/5/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa
import CoreLocation
import RxCocoa
import RxSwift

public protocol SearchViewModelProtocol {
    var input: SearchViewModelInput { get }
    var output: SearchViewModelOutput { get }
}

public protocol SearchViewModelInput {

    var textSearchPublish: PublishSubject<String> { get }
    var enableFullSearchModePublisher: PublishSubject<Bool> { get }
    var selectPlaceObjPublisher: PublishSubject<PlaceObj?> { get }
}

public protocol SearchViewModelOutput {

    // Origin
    var currentPlaceDriver: Driver<PlaceObj> { get }

    // Search
    var searchPlacesVar: Variable<[PlaceObj]> { get }
    var loadingDriver: Driver<Bool> { get }
}

// MARK: - SearchViewModel
open class SearchViewModel: SearchViewModelProtocol, SearchViewModelInput, SearchViewModelOutput {

    // MARK: - View Model
    public var input: SearchViewModelInput { return self }
    public var output: SearchViewModelOutput { return self }

    // MARK: - Input
    public var textSearchPublish = PublishSubject<String>()
    public var selectPlaceObjPublisher = PublishSubject<PlaceObj?>()
    public var enableFullSearchModePublisher = PublishSubject<Bool>()

    // MARK: - Output
    public var searchPlacesVar = Variable<[PlaceObj]>([])
    public let loadingDriver: Driver<Bool>
    public var currentPlaceDriver: Driver<PlaceObj> {
        return mapService.output.currentPlaceObs
            .asDriver(onErrorJustReturn: PlaceObj.invalid)
    }

    // MARK: - Variable
    fileprivate var personalOrHistoryPlacesVar = Variable<[PlaceObj]>([])
    fileprivate let mapService: MapService
    fileprivate let disposeBag = DisposeBag()

    // MARK: - Init
    public init(uberService: UberService = UberService(),
                mapService: MapService = MapService.share,
                googleMapService: GoogleMapService = GoogleMapService()) {

        self.mapService = mapService

        // Load personal or history place
        let personalPlace = uberService
            .personalPlaceObserver()
            .startWith([]) // Don't need to wait -> Should show history palce first

        let historyPlace = uberService.historyObserver

        Observable.combineLatest([personalPlace, historyPlace])
            .map { (combine) -> [PlaceObj] in
                let personPlaces = combine.first!
                let historyPlaces = combine.last!
                return personPlaces + historyPlaces
            }.bind(to: personalOrHistoryPlacesVar)
            .addDisposableTo(disposeBag)

        // Trigger
        uberService.reloadHistoryTrigger.onNext()

        // Text Search
        let shared = textSearchPublish
            .asObservable()
            .share()

        // Reset Empty data while fetching
        let emptyOb = shared
            .filter({ !$0.isEmpty })
            .map { _ -> [PlaceObj] in return [] }

        // Search from Google Service
        let searchPlaceOb = shared
            .filter { !$0.isEmpty }
            .debounce(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .withLatestFrom(mapService.output.currentLocationVar.asObservable().filterNil(),
                            resultSelector: { (namePlace, location) -> (String, CLLocationCoordinate2D) in
                                return (namePlace, location.coordinate)
            })
            .flatMapLatest { return googleMapService.searchPlaces(with: $0.0, currentLocation: $0.1) }
            .startWith([])

        let personalOrHistoryOb = shared
            .distinctUntilChanged()
            .filter({ $0.isEmpty })
            .withLatestFrom(personalOrHistoryPlacesVar.asObservable())
            .startWith([])

        let searchPlaceData = Observable.combineLatest(shared, personalOrHistoryOb, searchPlaceOb) { (condition, thenObs, elseObs) -> [PlaceObj] in
            if condition.isEmpty {
                return thenObs
            }
            return elseObs
        }

        // Merage into searchPlace
        let searchFinishOb = Observable.merge([searchPlaceData,
                                               emptyOb])
            .skip(1)
            .share()

        searchFinishOb
            .bind(to: searchPlacesVar)
            .addDisposableTo(disposeBag)

        // Loader
        let startLoadingOb = Observable.merge([searchPlaceOb, personalOrHistoryOb]).map { _ in true }
        let stopLoadingOb = searchFinishOb.map { _ in false }
        loadingDriver = Observable.merge([startLoadingOb, stopLoadingOb])
            .map({ !$0 })
            .asDriver(onErrorJustReturn: false)

        // Save History place
        let selectedPlaceObs = selectPlaceObjPublisher.asObserver().share()
        selectedPlaceObs
            .subscribe(onNext: { placeObj in
                guard let placeObj = placeObj else { return }
                guard let currentUser = UberAuth.share.currentUser else { return }

                // Only save normal place to history
                // Don't save personal place
                guard placeObj.placeType == .place else { return }

                // Save history
                currentUser.saveHistoryPlace(placeObj)

                // Load again
                uberService.reloadHistoryTrigger.onNext()
            })
            .addDisposableTo(disposeBag)

    }
}
