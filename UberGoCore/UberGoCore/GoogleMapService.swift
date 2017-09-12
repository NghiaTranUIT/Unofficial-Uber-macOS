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

public final class GoogleMapService {

    // MARK: - Pulbic
    public func searchPlaces(with name: String, currentLocation: CLLocationCoordinate2D) -> Observable<[PlaceObj]> {
        let param = PlaceSearchRequestParam(keyword: name, location: currentLocation)
        return PlaceSearchRequest(param).toObservable()
    }

    public func geocodingPlace(with placeObj: UberPersonalPlaceObj) -> Observable<PlaceObj> {
        let param = GoogleGeocodingRequestParam(personalPlaceObj: placeObj)
        return GoogleGeocodingRequest(param).toObservable()
            .map({ (geocodingObj) -> PlaceObj in
                return PlaceObj(geocodingObj: geocodingObj, placeType: placeObj.placeType)
            })
    }
}
