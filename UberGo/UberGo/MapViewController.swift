//
//  MapViewController.swift
//  UberGo
//
//  Created by Nghia Tran on 6/2/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa
import UberGoCore
import Mapbox
import RxSwift
import CoreLocation
import RxOptional

class MapViewController: BaseViewController {

    // MARK: - OUTLET
    fileprivate var mapView: MGLMapView!

    // MARK: - Variable
    fileprivate var viewModel: MapViewModel!

    // MARK: - View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Map View
        self.initMapView()

        // View Model
        self.viewModel = MapViewModel()
        self.viewModel.input.getCurrentLocationPublish.onNext()
        self.viewModel.output.currentLocationDriver
            .filterNil()
            .drive(onNext: {[weak self] location in
                guard let `self` = self else {
                    return
                }
                print("setCenter")
                self.mapView.setCenter(location.coordinate, animated: true)
            })
        .addDisposableTo(self.disposeBag)
    }

    fileprivate func initMapView() {
        self.mapView = MGLMapView(frame: self.view.bounds)
        self.mapView.delegate = self
        self.mapView.zoomLevel = 14
        self.mapView.styleURL = MGLStyle.darkStyleURL(withVersion: 9)
        self.mapView.translatesAutoresizingMaskIntoConstraints = true
        self.view.addSubview(self.mapView)
    }
}

extension MapViewController: MGLMapViewDelegate {

}
