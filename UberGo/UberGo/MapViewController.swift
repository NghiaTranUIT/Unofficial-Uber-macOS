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
import RxSwift
import UberGoCore

class MapViewController: BaseViewController {

    // MARK: - OUTLET
    fileprivate var mapView: MGLMapView!
    fileprivate var searchCollectionView: SearchCollectionView!

    // MARK: - Variable
    fileprivate var viewModel: MapViewModel!
    fileprivate var currentLocationPoint: MGLPointAnnotation?
    fileprivate var searchBarView: SearchBarView!
    fileprivate var isFirstTime = true

    fileprivate var searchPlaceObjs: [PlaceObj] {
        return self.viewModel.output.searchPlaceObjsVariable.value
    }

    // MARK: - View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Common
        self.initCommon()

        // Map View
        self.initMapView()

        // Search
        self.initSearchBarView()

        // CollectionView
        self.initSearchCollectionView()

        // View Model
        self.binding()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
    }

    fileprivate func binding() {
        self.viewModel = MapViewModel()
        self.viewModel.input.startUpdateLocationTriggerPublisher.onNext(true)
        self.viewModel.output.currentLocationDriver
            .filterNil()
            .drive(onNext: {[weak self] location in
                guard let `self` = self else {
                    return
                }
                print("setCenter \(location)")
//                self.updateCurrentLocation(point: location.coordinate)
                self.addPoint(point: location.coordinate)
                self.mapView.setCenter(location.coordinate, animated: true)
            })
            .addDisposableTo(self.disposeBag)

        self.viewModel.output.nearestPlaceDriver.drive(onNext: { [weak self] nearestPlaceObj in
                guard let `self` = self else { return }
                print("Found Nearst Place = \(nearestPlaceObj)")
                self.searchBarView.updateNestestPlace(nearestPlaceObj)
            })
            .addDisposableTo(self.disposeBag)

        // Input search
        self.searchBarView.textSearchDidChangedDriver
            .drive(onNext: {[unowned self] text in
                self.viewModel.input.textSearchPublish.onNext(text)
            })
            .addDisposableTo(self.disposeBag)

        // Reload
        self.viewModel.output.searchPlaceObjsVariable
            .asObservable()
            .subscribe(onNext: {[weak self] placeObjs in
                guard let `self` = self else { return }
                print("Place Search FOUND = \(placeObjs.count)")
                self.searchCollectionView.reloadData()
            })
            .addDisposableTo(self.disposeBag)

        self.viewModel.output.personPlaceObjsVariable
            .asObservable()
            .subscribe(onNext: {[weak self] placeObjs in
                guard let `self` = self else { return }
                print("Personal place FOUND = \(placeObjs.count)")
                if self.searchBarView.textSearch == "" {
                    self.searchCollectionView.reloadData()
                }
            })
            .addDisposableTo(self.disposeBag)

        // Loader
        self.viewModel.output.loadingPublisher.subscribe(onNext: {[weak self] isLoading in
            guard let `self` = self else {
                return
            }
            self.searchBarView.loaderIndicatorView(isLoading)
        }).addDisposableTo(self.disposeBag)
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

    fileprivate func addPoint(point: CLLocationCoordinate2D) {
        let location = MGLPointAnnotation()
        location.coordinate = point
        location.title = "Here"

        // Add
        self.mapView.addAnnotation(location)
    }

    fileprivate func addProductObjs(_ productionObjs: [ProductObj]) {

    }
}

// MARK: - Private
extension MapViewController {

    fileprivate func initCommon() {
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.white.cgColor
    }

    fileprivate func initMapView() {
        self.mapView = MGLMapView(frame: self.view.bounds)
        self.mapView.delegate = self
        self.mapView.zoomLevel = 14
        self.mapView.styleURL = MGLStyle.darkStyleURL(withVersion: 9)
        self.mapView.translatesAutoresizingMaskIntoConstraints = true
        self.view.addSubview(self.mapView)
    }

    fileprivate func initSearchBarView() {
        self.searchBarView = SearchBarView.viewFromNib(with: BundleType.app)!
        self.searchBarView.delegate = self
        self.searchBarView.configureView(with: self.view)
    }

    fileprivate func initSearchCollectionView() {
        self.searchCollectionView = SearchCollectionView.viewFromNib(with: BundleType.app)!
        self.searchCollectionView.delegate = self
        self.searchCollectionView.configureView(parenView: self.view, searchBarView: self.searchBarView)
    }
}

// MARK: - MGLMapViewDelegate
extension MapViewController: MGLMapViewDelegate {

    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
}

// MARK: - SearchBarViewDelegate
extension MapViewController: SearchBarViewDelegate {

    func searchBar(_ sender: SearchBarView, layoutStateDidChanged state: SearchBarViewLayoutState) {
        self.searchCollectionView.layoutStateChanged(state)
    }
}

extension MapViewController: SearchCollectionViewDelegate {
    func searchCollectionViewNumberOfPlace() -> Int {
        return self.searchPlaceObjs.count
    }

    func searchCollectionView(_ sender: SearchCollectionView, atIndex: IndexPath) -> PlaceObj {
        return self.searchPlaceObjs[atIndex.item]
    }
}
