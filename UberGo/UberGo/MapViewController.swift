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
    fileprivate var collectionView: SearchCollectionView!

    // MARK: - Variable
    fileprivate var viewModel: MapViewModel!
    fileprivate var currentLocationPoint: MGLPointAnnotation?
    fileprivate var searchBarView: SearchBarView!
    fileprivate var isFirstTime = true

    fileprivate var searchPlaceObjs: [PlaceObj] {
        return self.viewModel.output.searchPlaceObjsVariable.value
    }

    fileprivate var personPlaceObjs: [UberPersonalPlaceObj] {
        return self.viewModel.output.personPlaceVariable.value
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
        self.initCollectionView()

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
                //self.updateCurrentLocation(point: location.coordinate)
                self.addPoint(point: location.coordinate)
                self.mapView.setCenter(location.coordinate, animated: true)
            })
            .addDisposableTo(self.disposeBag)

        // Show Product available
//        self.viewModel.output.productsVariable.asDriver().drive(onNext: { [weak self] productObjs in
//            guard let `self` = self else { return }
//            print("Found available products = \(productObjs)")
//            self.addProductObjs(productObjs)
//        })
//        .addDisposableTo(self.disposeBag)

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
        self.viewModel.output.searchPlaceObjsVariable.asObservable()
        .subscribe(onNext: {[weak self] placeObjs in
            guard let `self` = self else { return }
            print("Place Search FOUND = \(placeObjs.count)")
            self.collectionView.reloadData()
        })
        .addDisposableTo(self.disposeBag)

        self.viewModel.output.personPlaceVariable.asObservable()
            .subscribe(onNext: {[weak self] placeObjs in
                guard let `self` = self else { return }
                print("Personal place FOUND = \(placeObjs.count)")
                if self.searchBarView.textSearch == "" {
                    self.collectionView.reloadData()
                }
            })
            .addDisposableTo(self.disposeBag)
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

    fileprivate func initCollectionView() {
        self.collectionView = SearchCollectionView(defaultValue: true)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.allowsMultipleSelection = false
        self.collectionView.allowsEmptySelection = false
        self.collectionView.configureView(parenView: self.view, searchBarView: self.searchBarView)

        // Register
        let nib = NSNib(nibNamed: "SearchPlaceCell", bundle: nil)
        self.collectionView.register(nib, forItemWithIdentifier: "SearchPlaceCell")

        // Flow
        let flow = SearchCollectionViewFlowLayout()
        self.collectionView.collectionViewLayout = flow
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
        self.collectionView.layoutStateChanged(state)
    }
}

// MARK: - NSCollectionViewDataSource
extension MapViewController: NSCollectionViewDataSource {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {

        return self.searchPlaceObjs.count
    }

    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath)
    -> NSCollectionViewItem {
        return self.getSearchCell(with: collectionView, indexPath: indexPath)
    }

    fileprivate func getSearchCell(with collectionView: NSCollectionView, indexPath: IndexPath)
    -> NSCollectionViewItem {

        guard let cell = collectionView.makeItem(withIdentifier: "SearchPlaceCell", for: indexPath)
            as? SearchPlaceCell else {
                return NSCollectionViewItem()
        }

        let placeObj = self.searchPlaceObjs[indexPath.item]
        cell.configurePlaceCell(placeObj)
        return cell
    }
}

// MARK: - NSCollectionViewDelegate
extension MapViewController: NSCollectionViewDelegate, NSCollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        print("Did Select cell \(indexPaths)")
    }
}
