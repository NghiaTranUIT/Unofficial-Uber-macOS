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
import MapboxDirections
import RxCocoa
import RxSwift
import UberGoCore

protocol MapViewControllerDelegate: class {

    func shouldRequestEstimateTrip(to data: UberRequestTripData?)
}

class MapViewController: BaseViewController {

    // MARK: - View
    fileprivate lazy var mapView: UberMapView = self.lazyInitUberMapView()

    // MARK: - Variable
    fileprivate var mapViewModel: MapViewModelProtocol!
    public weak var delegate: MapViewControllerDelegate?

    // MARK: - Init
    public class func buildController(_ mapViewModel: MapViewModelProtocol) -> MapViewController {
        let controller = MapViewController(nibName: "MapViewController", bundle: nil)!
        controller.mapViewModel = mapViewModel
        return controller
    }

    // MARK: - View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Common
        initCommon()

        // Binding
        mapView.setupViewModel(mapViewModel)
        binding()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
    }

    fileprivate func binding() {

        // Trigger Get location
        mapViewModel.input.startUpdateLocationTriggerPublisher.onNext(true)

        // Force load Uber data
        UberAuth.share.currentUser?.reloadUberDataPublisher.onNext()

        // Selected Place
        mapViewModel.output.selectedPlaceObjDriver
            .drive(onNext: {[weak self] placeObj in
                guard let `self` = self else { return }

                if let placeObj = placeObj {
                    // Request data (trip, estimation, route)
                    guard let currentLocation = self.mapViewModel.output.currentLocationVar.value else { return }
                    let from = PlaceObj(coordinate: currentLocation.coordinate)
                    let data = UberRequestTripData(from: from, to: placeObj)
                    self.delegate?.shouldRequestEstimateTrip(to: data)
                } else {
                    self.delegate?.shouldRequestEstimateTrip(to: nil)
                    self.mapView.addDestinationPlaceObj(nil)
                }
            })
            .addDisposableTo(disposeBag)
    }

    // MARK: - Public
    public func resetAllData() {
        mapView.resetAllData()
    }

    public func updateCurrentTripLayout(_ tripObj: TripObj) {
        mapView.updateCurrentTripLayout(tripObj)
    }

    public func addDestination(_ placeObj: PlaceObj?) {
        mapView.addDestinationPlaceObj(placeObj)
    }

    public func startUpdateLocation() {
        mapViewModel.input.startUpdateLocationTriggerPublisher.onNext(true)
    }

    public func selectPlace(_ placeObj: PlaceObj?) {
        mapViewModel.input.selectPlaceObjPublisher.onNext(placeObj)
    }

    public func requestRoute(to placeObj: PlaceObj) {
        mapViewModel.input.routeToDestinationPublisher.onNext(placeObj)
    }

    public func requestRoute(for tripObj: TripObj) {
        mapViewModel.input.routeForCurrentTripPublisher.onNext(tripObj)
    }
}

// MARK: - Private
extension MapViewController {

    fileprivate func initCommon() {
        view.backgroundColor = NSColor.white
    }

    fileprivate func lazyInitUberMapView() -> UberMapView {
        let map = UberMapView(frame: CGRect.zero)
        map.uberMapDelegate = self
        map.configureLayout(self.view)
        return map
    }

    fileprivate func lazyInitMenuView() -> MenuView {
        return MenuView.viewFromNib(with: BundleType.app)!
    }
}

extension MapViewController: UberMapViewDelegate {
    func uberMapViewTimeEstimateForOriginAnnotation() -> TimeEstimateObj? {
//        return uberViewModel.output.selectedProduct.value?.estimateTime
        return nil
    }
}
