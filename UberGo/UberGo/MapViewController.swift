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

enum MapViewLayoutState {
    case expand
    case minimal
    case navigation
}

class MapViewController: BaseViewController {

    // MARK: - OUTLET
    fileprivate var mapView: UberMapView!
    fileprivate var searchCollectionView: SearchCollectionView!
    fileprivate lazy var requestUberView: RequestUberView = self.lazyInitRequestUberView()

    @IBOutlet fileprivate weak var exitNavigateBtn: NSButton!
    @IBOutlet fileprivate weak var mapContainerView: NSView!
    @IBOutlet fileprivate weak var mapContainerViewBottom: NSLayoutConstraint!
    @IBOutlet fileprivate weak var bottomBarView: NSView!
    @IBOutlet fileprivate weak var bottomBarViewHeight: NSLayoutConstraint!

    // MARK: - Variable
    fileprivate var viewModel: MapViewModel!
    fileprivate var searchBarView: SearchBarView!
    fileprivate var isFirstTime = true
    fileprivate lazy var webController: SurgeHrefConfirmationController = self.lazyInitWebController()
    fileprivate var paymentMethodController: PaymentMethodsController?

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
        self.notificationBinding()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
    }

    deinit {
        NotificationService.removeAllObserve(self)
    }

    fileprivate func binding() {
        self.viewModel = MapViewModel()
        self.viewModel.input.startUpdateLocationTriggerPublisher.onNext(true)
        self.viewModel.output.currentLocationDriver
            .filterNil()
            .drive(onNext: {[weak self] location in
                guard let `self` = self else { return }

                print("setCenter \(location)")
                self.mapView.addOriginPoint(location.coordinate)
            })
            .addDisposableTo(self.disposeBag)

        // Force load Uber data
        UserObj.currentUser?.reloadUberDataPublisher.onNext()

        // Nearest place
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

            let state = placeObj != nil ? MapViewLayoutState.navigation :
                MapViewLayoutState.minimal

            // Layout
            self.updateLayoutState(state)
            self.mapView.addDestinationPlaceObj(placeObj)

            // Request Product + Estimate Uber
            guard let placeObj = placeObj else { return }
            guard let currentLocation = self.viewModel.currentLocationVariable.value else { return }
            guard let currentUser = UserObj.currentUser else { return }

            let data = UberData(placeObj: placeObj, from: currentLocation.coordinate)
            self.requestUberView.viewModel.input.selectedPlacePublisher.onNext(data)
        })
        .addDisposableTo(self.disposeBag)

        // Draw map
        self.viewModel.output.selectedDirectionRouteObserver.subscribe(onNext: {[weak self] (route) in
            guard let `self` = self else {
                return
            }
            self.mapView.drawDirectionRoute(route)
        })
        .addDisposableTo(self.disposeBag)

        // Show or hide Bottom bar
        self.requestUberView.viewModel.output.isLoadingAvailableProductPublisher
        .subscribe(onNext: { isLoading in
            Logger.info("isLoading Available Products = \(isLoading)")
        })
        .addDisposableTo(self.requestUberView.disposeBag)

        // Show href
        self.requestUberView.viewModel.output.showSurgeHrefDriver
        .drive(onNext: {[weak self] surgeObj in
            guard let `self` = self else { return }
            Logger.info("SHOW CONFIRMATION = \(surgeObj.surgeConfirmationHref ?? "")")
            self.showSurgeHrefView(surgeObj)
        })
        .addDisposableTo(self.requestUberView.disposeBag)

        // Trip
        self.requestUberView.viewModel.output.normalTripDriver.drive(onNext: { (createTripObj) in
            Logger.info("Start Request Normal TRIP = \(createTripObj)")
        })
        .addDisposableTo(self.requestUberView.disposeBag)
    }

    fileprivate func notificationBinding() {
        NotificationService.observeNotificationType(.showPaymentMethodsView,
                                                    observer: self,
                                                    selector: #selector(self.showPaymentMethodView(noti:)),
                                                    object: nil)
        NotificationService.observeNotificationType(.handleSurgeCallback,
                                                    observer: self,
                                                    selector: #selector(self.handleSurgeCallback(noti:)),
                                                    object: nil)
    }

    @objc func showSurgeHrefView(_ surgeObj: SurgePriceObj) {
        self.webController.configureWebView(with: surgeObj)
        self.presentViewControllerAsSheet(self.webController)
    }

    @objc func showPaymentMethodView(noti: Notification) {
        let controller = PaymentMethodsController(nibName: "PaymentMethodsController", bundle: nil)!
        controller.delegate = self
        self.presentViewControllerAsSheet(controller)
        self.paymentMethodController = controller
    }

    @objc func handleSurgeCallback(noti: Notification) {
        guard let event = noti.object as? NSAppleEventDescriptor else { return }
        guard let url = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue else {
            return
        }

        // Hide
        self.dismissViewController(self.webController)

        // Get
        self.requestUberView.viewModel.input.requestUberWithSurgeIDPublisher.onNext(url)
    }

    @IBAction func exitNavigateBtnOnTapped(_ sender: Any) {
        self.updateLayoutState(.minimal)

        // Remove current
        self.viewModel.input.didSelectPlaceObjPublisher.onNext(nil)
    }

    fileprivate func updateLayoutState(_ state: MapViewLayoutState) {
        self.searchCollectionView.layoutStateChanged(state)
        self.searchBarView.layoutState = state

        switch state {
        case .expand:
            fallthrough
        case .minimal:

            // Force Layout
            self.mapContainerViewBottom.constant = 0
            self.view.layoutSubtreeIfNeeded()

            // Fade out
            NSAnimationContext.defaultAnimate({ _ in
                self.exitNavigateBtn.alphaValue = 0
            })
        case .navigation:

            // Force layout
            self.mapContainerViewBottom.constant = 305
            self.view.layoutSubtreeIfNeeded()

            // Fade in
            NSAnimationContext.defaultAnimate({ _ in
                self.exitNavigateBtn.alphaValue = 1
            })
        }
    }
}

// MARK: - Private
extension MapViewController {

    fileprivate func initCommon() {
        self.view.backgroundColor = NSColor.white
        self.exitNavigateBtn.alphaValue = 0
        self.bottomBarView.backgroundColor = NSColor(hexString: "#343332")
    }

    fileprivate func initMapView() {
        self.mapView = UberMapView(frame: self.mapContainerView.bounds)
        self.mapView.configureLayout(self.mapContainerView, exitBtn: self.exitNavigateBtn)
    }

    fileprivate func initSearchBarView() {
        self.searchBarView = SearchBarView.viewFromNib(with: BundleType.app)!
        self.searchBarView.delegate = self
        self.mapContainerView.addSubview(self.searchBarView, positioned: .below, relativeTo: self.exitNavigateBtn)
        self.searchBarView.configureView(with: self.mapContainerView)
    }

    fileprivate func initSearchCollectionView() {
        self.searchCollectionView = SearchCollectionView.viewFromNib(with: BundleType.app)!
        self.searchCollectionView.delegate = self
        self.mapContainerView.addSubview(self.searchCollectionView,
                                         positioned: .below,
                                         relativeTo: self.exitNavigateBtn)
        self.searchCollectionView.configureView(parenView: self.mapContainerView, searchBarView: self.searchBarView)
    }

    fileprivate func lazyInitRequestUberView() -> RequestUberView {
        let uberView = RequestUberView.viewFromNib(with: BundleType.app)!
        uberView.configureLayout(self.bottomBarView)
        return uberView
    }

    fileprivate func lazyInitWebController() -> SurgeHrefConfirmationController {
        return SurgeHrefConfirmationController(nibName: "SurgeHrefConfirmationController", bundle: nil)!
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

extension MapViewController: PaymentMethodsControllerDelegate {

    func paymentMethodsControllerShouldDismiss(_ sender: PaymentMethodsController) {
        guard let controller = self.paymentMethodController else { return }
        self.dismissViewController(controller)
        self.paymentMethodController = nil
    }
}
