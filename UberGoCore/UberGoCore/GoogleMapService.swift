//
//  GoogleMapService.swift
//  UberGoCore
//
//  Created by Nghia Tran on 7/31/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import CoreLocation
import Foundation
import RxSwift

open class GoogleMapService {

    // MARK: - Pulbic
    public func searchPlaces(with name: String, currentLocation: CLLocationCoordinate2D) -> Observable<[PlaceObj]> {
        let param = PlaceSearchRequestParam(keyword: name, location: currentLocation)
        return PlaceSearchRequest(param).toObservable()
    }
}