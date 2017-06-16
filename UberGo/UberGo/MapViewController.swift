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
import RxSwift
import UberGoCore

enum MapViewLayoutState {
    case expand
    case minimal
    case navigate
}

class MapViewController: BaseViewController {

    // MARK: - OUTLET
    fileprivate var mapView: MGLMapView!
    fileprivate var searchCollectionView: SearchCollectionView!
    @IBOutlet fileprivate weak var exitNavigateBtn: NSButton!

    // MARK: - Variable
    fileprivate var viewModel: MapViewModel!
    fileprivate var searchBarView: SearchBarView!
    fileprivate var isFirstTime = true

    fileprivate var searchPlaceObjs: [PlaceObj] {
        return self.viewModel.output.searchPlaceObjsVariable.value
    }

    // Origin
    fileprivate var originPoint: MGLPointAnnotation?

    // Destination
    fileprivate var destinationPlaceObj: PlaceObj?
    fileprivate var destinationPoint: MGLPointAnnotation?
    fileprivate var directionRoute: MGLPolyline?

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

        // Loader
        self.viewModel.output.loadingPublisher.subscribe(onNext: {[weak self] isLoading in
            guard let `self` = self else {
                return
            }
            self.searchBarView.loaderIndicatorView(isLoading)
        }).addDisposableTo(self.disposeBag)

        // Selected Place
        self.viewModel.output.selectedPlaceObjDriver.drive(onNext: {[weak self] placeObj in
            guard let `self` = self else { return }

            let state = placeObj != nil ? MapViewLayoutState.navigate :
                MapViewLayoutState.minimal

            // Layout
            self.updateLayoutState(state)
            self.addDestinationPlaceObj(placeObj)
        })
        .addDisposableTo(self.disposeBag)

        // Draw map
        self.viewModel.output.selectedDirectionRouteObserver.subscribe(onNext: {[weak self] (route) in
            guard let `self` = self else {
                return
            }
            self.drawDirectionRoute(route)
        })
        .addDisposableTo(self.disposeBag)
    }

    fileprivate func addPoint(point: CLLocationCoordinate2D) {

        // Remove if need
        if let currentPoint = self.originPoint {
            self.mapView.removeAnnotation(currentPoint)
            self.originPoint = nil
        }

        let location = MGLPointAnnotation()
        location.coordinate = point
        location.title = "Here"

        // Add
        self.mapView.addAnnotation(location)
        self.originPoint = location

        // CentralizeMap
        self.centralizeMap()

    }

    fileprivate func addProductObjs(_ productionObjs: [ProductObj]) {

    }

    fileprivate func addDestinationPlaceObj(_ placeObj: PlaceObj?) {
        self.destinationPlaceObj = placeObj

        // Remove if need
        if let currentPoint = self.destinationPoint {
            self.mapView.removeAnnotation(currentPoint)
            self.destinationPoint = nil
        }

        // Remove
        guard let placeObj = placeObj else {
            return
        }

        // Add
        guard let coordinate = placeObj.coordinate2D else {
            return
        }
        self.destinationPoint = MGLPointAnnotation()
        self.destinationPoint!.coordinate = coordinate
        self.destinationPoint!.title = placeObj.name
        self.mapView.addAnnotation(self.destinationPoint!)

        // CentralizeMap
        self.centralizeMap()
    }

    fileprivate func centralizeMap() {
        guard let annotations = self.mapView.annotations else {
            return
        }
        let edge = EdgeInsets(top: 200, left: 70, bottom: 70, right: 70)
        self.mapView.showAnnotations(annotations, edgePadding: edge, animated: true)
    }

    fileprivate func drawDirectionRoute(_ route: Route?) {
        guard let route = route else {
            // Remove if need
            if let directionRoute = self.directionRoute {
                self.mapView.removeAnnotation(directionRoute)
                self.directionRoute = nil
            }
            return
        }

        if route.coordinateCount > 0 {

            // Remove if need
            if let directionRoute = self.directionRoute {
                self.mapView.removeAnnotation(directionRoute)
                self.directionRoute = nil
            }

            // Convert the route’s coordinates into a polyline.
            var routeCoordinates = route.coordinates!
            let routeLine = MGLPolyline(coordinates: &routeCoordinates, count: route.coordinateCount)

            // Add the polyline to the map and fit the viewport to the polyline.
            self.mapView.addAnnotation(routeLine)
            self.directionRoute = routeLine

            // Centerizal
            self.centralizeMap()
        } else {
            assert(false, "route.coordinateCount == 0")
        }
    }

    fileprivate func updateLayoutState(_ state: MapViewLayoutState) {
        self.searchCollectionView.layoutStateChanged(state)
        self.searchBarView.layoutState = state

        switch state {
        case .expand:
            fallthrough
        case .minimal:
            NSAnimationContext.runAnimationGroup({ context in
                context.allowsImplicitAnimation = true
                context.duration = 0.22
                context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
                self.exitNavigateBtn.alphaValue = 0
            }, completionHandler: nil)
        case .navigate:
            NSAnimationContext.runAnimationGroup({ context in
                context.allowsImplicitAnimation = true
                context.duration = 0.22
                context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
                self.exitNavigateBtn.alphaValue = 1
            }, completionHandler: nil)
        }
    }

    @IBAction func exitNavigateBtnOnTapped(_ sender: Any) {
        self.updateLayoutState(.minimal)
    }

}

// MARK: - Private
extension MapViewController {

    fileprivate func initCommon() {
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.white.cgColor
        self.exitNavigateBtn.alphaValue = 0
    }

    fileprivate func initMapView() {
        self.mapView = MGLMapView(frame: self.view.bounds)
        self.mapView.delegate = self
        self.mapView.zoomLevel = 14
        self.mapView.styleURL = MGLStyle.darkStyleURL(withVersion: 9)
        self.mapView.translatesAutoresizingMaskIntoConstraints = true
        self.mapView.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
        self.view.addSubview(self.mapView, positioned: .below, relativeTo: self.exitNavigateBtn)
    }

    fileprivate func initSearchBarView() {
        self.searchBarView = SearchBarView.viewFromNib(with: BundleType.app)!
        self.searchBarView.delegate = self
        self.view.addSubview(self.searchBarView, positioned: .below, relativeTo: self.exitNavigateBtn)
        self.searchBarView.configureView(with: self.view)
    }

    fileprivate func initSearchCollectionView() {
        self.searchCollectionView = SearchCollectionView.viewFromNib(with: BundleType.app)!
        self.searchCollectionView.delegate = self
        self.view.addSubview(self.searchCollectionView, positioned: .below, relativeTo: self.exitNavigateBtn)
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

    func searchBar(_ sender: SearchBarView, layoutStateDidChanged state: MapViewLayoutState) {
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

    func searchCollectionView(_ sender: SearchCollectionView, didSelectItem atIndex: IndexPath) {

        // Select
        let placeObj = self.searchPlaceObjs[atIndex.item]
        self.viewModel.input.didSelectPlaceObjPublisher.onNext(placeObj)
    }
}
