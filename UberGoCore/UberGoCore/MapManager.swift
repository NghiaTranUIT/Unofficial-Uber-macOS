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
    fileprivate lazy var locationManager: CLLocationManager = self.lazyLocationManager()
    fileprivate var locationBlock: MapAuthenticationBlock?

    // MARK: - Init
    public override init() {
        super.init()
    }

    // MARK: - Public
    public func requestLocation(with block: MapAuthenticationBlock?) {
        self.locationBlock = block
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
        guard let block = self.locationBlock else { return }
        guard let lastLocation = locations.last else { return }

        // Notify
        block(lastLocation, nil)
    }
}
