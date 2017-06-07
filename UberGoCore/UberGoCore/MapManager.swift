//
//  Map.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/4/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation
import MapKit
import RxSwift

public typealias MapAuthenticationBlock = (CLLocation?, Error?) -> Void

public enum MapManagerResult {
    case location(CLLocation)
    case error(Error)
}

open class MapManager: NSObject {

    // MARK: - Variable
    public var authenticateState: CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
    public var isLocationServiceEnable: Bool {
        return CLLocationManager.locationServicesEnabled()
    }
    public var currentLocationVariable = Variable<CLLocation?>(nil)
    public var nearestPlaceObverser: Observable<PlaceObj>!

    fileprivate lazy var locationManager: CLLocationManager = self.lazyLocationManager()
    fileprivate var locationBlock: MapAuthenticationBlock?
    fileprivate var shouldUpdateCurrentLocation = false
    fileprivate lazy var geoCoder: CLGeocoder = {
        return CLGeocoder()
    }()

    // MARK: - Init
    public override init() {
        super.init()

        self.nearestPlaceObverser = self.currentLocationVariable
            .asObservable()
            .filterNil()
            .flatMapLatest({ location -> Observable<PlaceObj> in
            return self.nearestPlaceObverser(location)
        })
    }

    // MARK: - Public
    public func requestLocation(with block: MapAuthenticationBlock?) {
        self.locationBlock = block
        self.shouldUpdateCurrentLocation = true
        self.locationManager.startUpdatingLocation()
    }

    public func requestLocationObserver() -> Observable<MapManagerResult> {

        return Observable<MapManagerResult>.create {[unowned self] observer -> Disposable in

            self.requestLocation(with: { (location, error) in

                if let location = location {
                    let result = MapManagerResult.location(location)
                    observer.onNext(result)
                }

                if let error = error {
                    let result = MapManagerResult.error(error)
                    observer.onNext(result)
                }

                // Complete
                observer.onCompleted()
            })

            return Disposables.create()
        }
    }

    public func nearestPlaceObverser(_ location: CLLocation) -> Observable<PlaceObj> {
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

extension MapManager {

    fileprivate func lazyLocationManager() -> CLLocationManager {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        return locationManager
    }
}

// MARK: - CLLocationManagerDelegate
extension MapManager: CLLocationManagerDelegate {

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
        self.locationBlock?(nil, error)
    }

    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("didChangeAuthorization \(status)")
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else { return }

        // Notify
        if self.shouldUpdateCurrentLocation {
            self.shouldUpdateCurrentLocation = false

            self.locationBlock?(lastLocation, nil)
            self.currentLocationVariable.value = lastLocation
        }
    }
}
