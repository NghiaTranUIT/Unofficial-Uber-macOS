//
//  MapViewController.swift
//  UberGo
//
//  Created by Nghia Tran on 6/2/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa
import CoreLocation
import Mapbox
import RxOptional
import RxSwift
import UberGoCore

class MapViewController: BaseViewController {

    // MARK: - OUTLET
    fileprivate var mapView: MGLMapView!

    // MARK: - Variable
    fileprivate var viewModel: MapViewModel!
    fileprivate var currentLocationPoint: MGLPointAnnotation?

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
                print("setCenter \(location)")
                self.updateCurrentLocation(point: location.coordinate)
                self.mapView.setCenter(location.coordinate, animated: true)
            })
        .addDisposableTo(self.disposeBag)

        // Show Product available
        self.viewModel.output.productsVariable.asDriver().drive(onNext: { productObjs in
            print("Found available products = \(productObjs)")
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

    fileprivate func updateCurrentLocation(point: CLLocationCoordinate2D) {
        if self.currentLocationPoint == nil {
            let location = MGLPointAnnotation()
            location.coordinate = point
            location.title = "Here"

            // Add
            self.currentLocationPoint = location
            self.mapView.addAnnotation(location)
        } else {
            self.currentLocationPoint?.coordinate = point
        }
    }
}

extension MapViewController: MGLMapViewDelegate {

    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
}
