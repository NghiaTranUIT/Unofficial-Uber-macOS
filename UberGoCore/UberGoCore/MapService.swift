//
//  Map.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/4/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation
import MapKit
import RxCocoa
import RxSwift

protocol MapServiceViewModel {
    var input: MapServiceInput { get }
    var output: MapServiceOutput { get }
}

protocol MapServiceInput {

}

protocol MapServiceOutput {

    var currentLocationVar: Variable<CLLocation?> { get }
    var currentPlaceObs: Observable<PlaceObj> { get }
    var authorizedDriver: Driver<Bool>! { get }
}

// MARK: - MapService
open class MapService: NSObject, MapServiceViewModel, MapServiceInput, MapServiceOutput {

    // MARK: - Input Output
    var input: MapServiceInput { return self }
    var output: MapServiceOutput { return self }

    // MARK: - Output
    public var currentLocationVar = Variable<CLLocation?>(nil)
    public var currentPlaceObs: Observable<PlaceObj>
    public var authorizedDriver: Driver<Bool>!

    // Private
    public static let share = MapService()
    fileprivate lazy var locationManager: CLLocationManager = self.lazyLocationManager()

    // MARK: - Init
    public override init() {

        // Current Place
        self.currentPlaceObs = self.currentLocationVar
            .asObservable()
            .filterNil()
            .take(1)
            .throttle(5.0, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .flatMapLatest({ MapService.currentPlaceObverser($0) })

        super.init()

        // Authorize
        self.authorizedDriver = Observable
            .deferred { [weak self] in
                let status = CLLocationManager.authorizationStatus()
                guard let `self` = self else { return Observable.empty() }
                return self.locationManager
                        .rx.didChangeAuthorizationStatus
                        .startWith(status)
            }
            .asDriver(onErrorJustReturn: CLAuthorizationStatus.notDetermined)
            .map {
                switch $0 {
                case .authorizedAlways:
                    return true
                default:
                    return false
                }
            }
    }

    // MARK: - Public
    public func startUpdatingLocation() {
        self.locationManager.startUpdatingLocation()
    }

    public func stopUpdatingLocation() {
        self.locationManager.stopUpdatingLocation()
    }

    fileprivate class func currentPlaceObverser(_ location: CLLocation) -> Observable<PlaceObj> {
        let param = PlaceSearchRequestParam(location: location.coordinate)
        return PlaceSearchRequest(param)
            .toObservable()
            .map({ return $0.first })
            .filterNil()
    }
}

extension MapService {

    fileprivate func lazyLocationManager() -> CLLocationManager {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        return locationManager
    }
}

// MARK: - CLLocationManagerDelegate
extension MapService: CLLocationManagerDelegate {

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Logger.info("Error \(error)")
    }

    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        Logger.info("didChangeAuthorization \(status)")
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else { return }

        // Notify
        self.currentLocationVar.value = lastLocation
    }
}
