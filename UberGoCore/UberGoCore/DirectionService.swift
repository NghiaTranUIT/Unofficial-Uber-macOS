//
//  DirectionService.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/14/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa
import MapboxDirections
import RxCocoa
import RxSwift

open class DirectionService {

    // MARK: - Public
    public func generateDirectionRoute(from originPlace: PlaceObj, to destinationPlace: PlaceObj) -> Observable<Route?> {
        return Observable<Route?>.create { (observer) -> Disposable in

            // Create option
            let options = RouteOptions(waypoints: [
                Waypoint(coordinate: originPlace.coordinate2D!,
                         name: originPlace.name!),
                Waypoint(coordinate: destinationPlace.coordinate2D!,
                         name: destinationPlace.name!)
                ])
            options.includesSteps = true

            // Get
            _ = Directions.shared.calculate(options, completionHandler: { (_, routes, error) in

                // Error
                if let error = error {
                    Logger.error("Error calculating directions: \(error)")
                    observer.onError(error)
                    observer.onCompleted()
                    return
                }

                // Get Route
                if let route = routes?.first, route.legs.first != nil {
                    observer.onNext(route)
                    observer.onCompleted()
                } else {
                    // Error
                    let error = NSError.customMessage("Can't find any Direction ROUTE")
                    Logger.error("Error calculating directions: \(error)")
                    observer.onError(error)
                    observer.onCompleted()
                    return
                }
            })

            // Return
            return Disposables.create()
        }
    }
}
