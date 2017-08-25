//
//  ServiceCoordinator.swift
//  UberGoCore
//
//  Created by Nghia Tran on 8/25/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation

open class ViewModelCoordinator {

    // MARK: - View models
    public let appViewModel: AppViewModelProtocol
    public let uberViewModel: UberServiceViewModelProtocol
    public let mapViewModel: MapViewModelProtocol
    public let searchViewModel: SearchViewModelProtocol
    public let authenViewModel: AuthenticationViewModelProtocol

    // MARK: - Init
    init(appViewModel: AppViewModelProtocol,
         uberViewModel: UberServiceViewModelProtocol,
         mapViewModel: MapViewModelProtocol,
         searchViewModel: SearchViewModelProtocol,
         authenViewModel: AuthenticationViewModelProtocol) {

        self.appViewModel = appViewModel
        self.uberViewModel = uberViewModel
        self.searchViewModel = searchViewModel
        self.mapViewModel = mapViewModel
        self.authenViewModel = authenViewModel
    }

    public class func defaultUber() -> ViewModelCoordinator {

        // Service
        let mapService = MapService()
        let uberService = UberService()
        let directionService = DirectionService()
        let googleMapService = GoogleMapService()

        // View model
        let appViewModel = AppViewModel(uberService: uberService)
        let mapViewModel = MapViewModel(mapService: mapService,
                               uberService: uberService,
                               directionService: directionService,
                               googleMapService: googleMapService)
        let uberViewModel = UberServiceViewModel(uberService: uberService)
        let searchViewModel = SearchViewModel(uberService: uberService,
                                              mapService: mapService,
                                              googleMapService: googleMapService)
        let authenViewModel = AuthenticationViewModel()
        return ViewModelCoordinator(appViewModel: appViewModel,
                                    uberViewModel: uberViewModel,
                                    mapViewModel: mapViewModel,
                                    searchViewModel: searchViewModel,
                                    authenViewModel: authenViewModel)
    }
}
