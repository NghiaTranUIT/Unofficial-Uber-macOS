//
//  MapViewController.swift
//  UberGo
//
//  Created by Nghia Tran on 6/2/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa
import UberGoCore
import MapKit
import RxSwift
import CoreLocation
import RxOptional

class MapViewController: BaseViewController {

    // MARK: - OUTLET
    @IBOutlet weak var mapView: MKMapView!

    // MARK: - Variable
    fileprivate var viewModel: MapViewModel!

    // MARK: - View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.mapView.delegate = self

        self.viewModel = MapViewModel()

        self.viewModel.input.getCurrentLocationPublish.onNext()

        self.viewModel.output.currentLocationDriver
            .map({ (location) -> MKCoordinateRegion? in
                guard let location = location else {
                    return nil
                }

                let span = MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.005)
                let region = MKCoordinateRegion(center: location.coordinate, span: span)
                return region

            })
            .filterNil()
            .drive(onNext: { (region) in
                print("Set region = ", region)
                self.mapView.setRegion(region, animated: true)
            })
        .addDisposableTo(self.disposeBag)
    }
}

extension MapViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        print(mapView.region)
    }
}
