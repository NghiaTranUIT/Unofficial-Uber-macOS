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
    fileprivate var collectionView: NSCollectionView!

    // MARK: - Variable
    fileprivate var viewModel: MapViewModel!
    fileprivate var currentLocationPoint: MGLPointAnnotation?
    fileprivate var searchBarView: SearchBarView!
    fileprivate var isFirstTime = true

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
        self.viewModel.input.getCurrentLocationPublish.onNext()
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
        self.searchBarView.configureView(with: self.view)
    }

    fileprivate func initCollectionView() {
        self.collectionView = NSCollectionView()
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.alphaValue = 0
        self.collectionView.isHidden = true
        self.collectionView.dataSource = self
        self.collectionView.delegate = self

        self.view.addSubview(self.collectionView)
        let top = NSLayoutConstraint(item: self.collectionView,
                                    attribute: .top,
                                    relatedBy: .equal,
                                    toItem: self.searchBarView,
                                    attribute: .bottom,
                                    multiplier: 1,
                                    constant: 0)
        let left = NSLayoutConstraint(item: self.collectionView,
                                     attribute: .left,
                                     relatedBy: .equal,
                                     toItem: self.view,
                                     attribute: .left,
                                     multiplier: 1,
                                     constant: 0)
        let right = NSLayoutConstraint(item: self.collectionView,
                                      attribute: .right,
                                      relatedBy: .equal,
                                      toItem: self.view,
                                      attribute: .right,
                                      multiplier: 1,
                                      constant: 0)
        let bottom = NSLayoutConstraint(item: self.collectionView,
                                          attribute: .bottom,
                                          relatedBy: .equal,
                                          toItem: self.view,
                                          attribute: .bottom,
                                          multiplier: 1,
                                          constant: 0)
        self.view.addConstraints([left, top, bottom, right])
    }
}

extension MapViewController: MGLMapViewDelegate {

    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
}

extension MapViewController: NSCollectionViewDataSource {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }

    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath)
        -> NSCollectionViewItem {
        return NSCollectionViewItem()
    }
}

extension MapViewController: NSCollectionViewDelegate {

}
