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

public typealias MapAuthenticationBlock = (CLLocation?, Error?) -> Void

public enum MapServiceResult {
    case location(CLLocation)
    case error(Error)

    // MARK: - Helper
    public var isError: Bool {
        switch self {
        case .error:
            return true
        default:
            return false
        }
    }

    public var isSuccess: Bool {
        switch self {
        case .location:
            return true
        default:
            return false
        }
    }

    public var location: CLLocation? {
        switch self {
        case .location(let _location):
            return _location
        default:
            return nil
        }
    }
}

extension MapServiceResult: Equatable {

    public static func == (lhs: MapServiceResult, rhs: MapServiceResult) -> Bool {
        if lhs.isError && rhs.isError {
            return true
        }

        if lhs.isSuccess && rhs.isSuccess {
            guard let lhsCoord = lhs.location?.coordinate else {
                return false
            }
            guard let rhsCoord = rhs.location?.coordinate else {
                return false
            }

            // Same coordinate
            if lhsCoord.latitude == rhsCoord.latitude &&
                lhsCoord.longitude == rhsCoord.longitude {
                return true
            }
        }

        return false
    }
}

open class MapService: NSObject {

    // MARK: - Variable
    public var authenticateState: CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
    public var isLocationServiceEnable: Bool {
        return CLLocationManager.locationServicesEnabled()
    }
    public var currentLocationVariable = Variable<CLLocation?>(nil)
    public var nearestPlaceObverser: Observable<PlaceObj>!
    public private(set) var authorized: Driver<Bool>!

    fileprivate lazy var locationManager: CLLocationManager = self.lazyLocationManager()
    fileprivate lazy var geoCoder: CLGeocoder = {
        return CLGeocoder()
    }()

    // MARK: - Init
    public override init() {
        super.init()

        self.nearestPlaceObverser = self.currentLocationVariable
            .asObservable()
            .filterNil()
            .take(1)
            .throttle(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .flatMapLatest({[unowned self] location -> Observable<PlaceObj> in
                return self.nearestPlaceObverser(location)
        })

        self.authorized = Observable.deferred { [weak locationManager] in
            let status = CLLocationManager.authorizationStatus()
            guard let locationManager = locationManager else {
                return Observable.just(status)
            }
            return locationManager
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

    fileprivate func nearestPlaceObverser(_ location: CLLocation) -> Observable<PlaceObj> {
        let param = PlaceSearchRequestParam(location: location.coordinate)
        return PlaceSearchRequest(param).toObservable()
        .map({ (placeObjs) -> PlaceObj in
            guard let nearestPlaceObj = placeObjs.first else {
                return PlaceObj.unknowPlace
            }
            return nearestPlaceObj
        })
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
        print("Error \(error)")
    }

    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("didChangeAuthorization \(status)")
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else { return }

        // Notify
        self.currentLocationVariable.value = lastLocation
    }
}
