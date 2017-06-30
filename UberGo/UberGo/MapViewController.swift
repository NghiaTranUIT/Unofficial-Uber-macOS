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
    case productSelection
    case tripFullActivity
    case tripMinimunActivity
}

class MapViewController: BaseViewController {

    // MARK: - OUTLET
    fileprivate var mapView: UberMapView!
    fileprivate var searchCollectionView: SearchCollectionView!
    fileprivate lazy var selectUberView: RequestUberView = self.lazyInitRequestUberView()
    fileprivate lazy var tripActivityView: TripActivityView = self.lazyInitTripActivityView()

    @IBOutlet fileprivate weak var exitNavigateBtn: NSButton!
    @IBOutlet fileprivate weak var mapContainerView: NSView!
    @IBOutlet fileprivate weak var bottomBarView: NSView!
    @IBOutlet fileprivate weak var containerViewHeight: NSLayoutConstraint!

    // MARK: - Variable
    fileprivate var mapViewModel = MapViewModel()
    fileprivate let uberViewModel = UberServiceViewModel()

    fileprivate var searchBarView: SearchBarView!
    fileprivate var isFirstTime = true
    fileprivate lazy var webController: SurgeHrefConfirmationController = self.lazyInitWebController()
    fileprivate var paymentMethodController: PaymentMethodsController?
    fileprivate var searchPlaceObjs: [PlaceObj] {
        return self.mapViewModel.output.searchPlaceObjsVariable.value
    }
    fileprivate var isShouldUpdateActivityLayout = true

    // Layout State
    fileprivate var _layoutState: MapViewLayoutState = .minimal {
        didSet {
            self.updateLayoutState(_layoutState)
        }
    }
    public fileprivate(set) var layoutState: MapViewLayoutState {
        get {
            return self._layoutState
        }
        set {
            guard newValue != _layoutState else { return }
            _layoutState = newValue
        }
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

        // 
        self.selectUberView.viewModel = self.uberViewModel

        // Trigger Get location
        self.mapViewModel.input.startUpdateLocationTriggerPublisher.onNext(true)

        // Update Location on map
        self.mapViewModel.output.currentLocationDriver
            .filterNil()
            .drive(onNext: {[weak self] location in
                guard let `self` = self else { return }

                print("setCenter \(location)")
                self.mapView.addOriginPoint(location.coordinate)
            })
            .addDisposableTo(self.disposeBag)

        // Force load Uber data
        UberAuth.share.currentUser?.reloadUberDataPublisher.onNext()

        // Nearest place
        self.mapViewModel.output.nearestPlaceDriver
            .drive(onNext: { [weak self] nearestPlaceObj in
                guard let `self` = self else { return }
                print("Found Nearst Place = \(nearestPlaceObj)")
                self.searchBarView.updateNestestPlace(nearestPlaceObj)
            })
            .addDisposableTo(self.disposeBag)

        // Input search
        self.searchBarView.textSearchDidChangedDriver
            .drive(onNext: {[unowned self] text in
                self.mapViewModel.input.textSearchPublish.onNext(text)
            })
            .addDisposableTo(self.disposeBag)

        // Reload search Place collectionView
        self.mapViewModel.output.searchPlaceObjsVariable
            .asObservable()
            .subscribe(onNext: {[weak self] placeObjs in
                guard let `self` = self else { return }
                print("Place Search FOUND = \(placeObjs.count)")
                self.searchCollectionView.reloadData()
            })
            .addDisposableTo(self.disposeBag)

        // Loader
        self.mapViewModel.output.loadingDriver
            .drive(onNext: {[weak self] (isLoading) in
                guard let `self` = self else { return }
                self.searchBarView.loaderIndicatorView(isLoading)
            }).addDisposableTo(self.disposeBag)

        // Selected Place
        self.mapViewModel.output.selectedPlaceObjDriver
            .drive(onNext: {[weak self] placeObj in
                guard let `self` = self else { return }

                // Draw
                self.mapView.addDestinationPlaceObj(placeObj)

                // Request Product + Estimate Uber
                if let placeObj = placeObj {
                    guard let currentLocation = self.mapViewModel.currentLocationVariable.value else { return }
                    let data = UberData(placeObj: placeObj, from: currentLocation.coordinate)
                    self.uberViewModel.input.selectedPlacePublisher.onNext(data)
                } else {
                    // Reset search bar
                    self.searchBarView.resetTextSearch()
                    self.searchBarView.loaderIndicatorView(false)
                }

            })
            .addDisposableTo(self.disposeBag)

        // Draw map
        self.mapViewModel.output.selectedDirectionRouteObserver
            .subscribe(onNext: {[weak self] (route) in
                guard let `self` = self else {
                    return
                }
                self.mapView.drawVisbileRoute(route)
            })
            .addDisposableTo(self.disposeBag)

        // Show or hide Bottom bar
        self.uberViewModel.output.isLoadingAvailableProductPublisher
            .subscribe(onNext: { isLoading in
                Logger.info("isLoading Available Products = \(isLoading)")
            })
            .addDisposableTo(self.disposeBag)

        // Show href
        self.uberViewModel.output.showSurgeHrefDriver
            .drive(onNext: {[weak self] surgeObj in
                guard let `self` = self else { return }
                Logger.info("SHOW CONFIRMATION = \(surgeObj.surgeConfirmationHref ?? "")")
                self.showSurgeHrefView(surgeObj)
            })
            .addDisposableTo(self.disposeBag)

        // Trip
        self.uberViewModel.output.normalTripDriver
            .drive(onNext: {[weak self] (createTripObj) in
                guard let `self` = self else { return }

                Logger.info("Start Request Normal TRIP = \(createTripObj)")

                // Update layout
                self.layoutState = .tripMinimunActivity

                // Trigger to start Timer
                self.uberViewModel.input.triggerCurrentTripPublisher.onNext()
            })
            .addDisposableTo(self.disposeBag)

        // Current Trip Status
        self.uberViewModel.output.currentTripStatusDriver
            .drive(onNext: {[weak self] (tripObj) in
                guard let `self` = self else { return }

                // Update
                self.handleLayoutAndData(tripObj)
            })
            .addDisposableTo(self.disposeBag)

        // Manually
        self.uberViewModel.output.manuallyCurrentTripStatusDriver
            .drive(onNext: {[weak self] tripObj in
                guard let `self` = self else { return }

                // Update
                self.handleLayoutAndData(tripObj)

                // Start Timer again
                if tripObj.isValidTrip {
                    self.uberViewModel.input.triggerCurrentTripPublisher.onNext()
                }
            })
            .addDisposableTo(self.disposeBag)

        // Get first check Trip Status
        self.uberViewModel.input.manuallyGetCurrentTripStatusPublisher.onNext()

        // Cancel
        self.uberViewModel.output.resetMapDriver
            .drive(onNext: {[weak self] _ in
                guard let `self` = self else { return }

                self.layoutState = .minimal

                // Reset data
                self.mapView.resetAllData()

                // Trigger location
                self.mapViewModel.input.startUpdateLocationTriggerPublisher.onNext(true)
            })
            .addDisposableTo(self.disposeBag)
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
        self.uberViewModel.input.requestUberWithSurgeIDPublisher.onNext(url)
    }

    @IBAction func exitNavigateBtnOnTapped(_ sender: Any) {

        // Minimal
        self.layoutState = .minimal

        // Remove current
        self.mapViewModel.input.didSelectPlaceObjPublisher.onNext(nil)
    }
}

// MARK: - Private
extension MapViewController {

    fileprivate func initCommon() {
        self.view.backgroundColor = NSColor.white
        self.exitNavigateBtn.alphaValue = 0
        self.bottomBarView.backgroundColor = NSColor.black
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
        uberView.backgroundColor = NSColor.black
        return uberView
    }

    fileprivate func lazyInitTripActivityView() -> TripActivityView {
        let uberView = TripActivityView.viewFromNib(with: BundleType.app)!
        uberView.backgroundColor = NSColor.black
        uberView.delegate = self
        return uberView
    }

    fileprivate func lazyInitWebController() -> SurgeHrefConfirmationController {
        return SurgeHrefConfirmationController(nibName: "SurgeHrefConfirmationController", bundle: nil)!
    }
}

// MARK: - Layout
extension MapViewController {

    fileprivate func updateLayoutState(_ state: MapViewLayoutState) {

        // Update state to sub-views
        self.searchBarView.layoutState = state
        self.searchCollectionView.layoutStateChanged(state)

        // Remove if need
        self.tripActivityView.removeFromSuperview()
        self.selectUberView.removeFromSuperview()

        // Layout
        let newHeight = self.preferredHeight(state)

        // Animate
        self.containerViewHeight.constant = newHeight
        self.view.layoutSubtreeIfNeeded()

        // Fade in
        NSAnimationContext.defaultAnimate({ _ in
            self.exitNavigateBtn.alphaValue = state == .productSelection ? 1 : 0
        })
    }

    fileprivate func preferredHeight(_ state: MapViewLayoutState) -> CGFloat {
        switch state {
        case .expand:
            fallthrough
        case .minimal:
            return 480

        case .productSelection:

            // Add
            if self.selectUberView.superview == nil {
                self.selectUberView.configureLayout(self.bottomBarView)
            }

            return 804

        case .tripFullActivity:

            // Add
            if self.tripActivityView.superview == nil {
                self.tripActivityView.configureLayout(self.bottomBarView)
            }

            return 480 + 324

        case .tripMinimunActivity:

            // Add
            if self.tripActivityView.superview == nil {
                self.tripActivityView.configureLayout(self.bottomBarView)
            }
            return 480 + 70
        }
    }
}

// MARK: - Activity View
extension MapViewController {

    fileprivate func updateLayoutWithTrip(_ tripObj: TripObj) {

        // Reset layout if there is no trip
        if tripObj.isValidTrip {
            if tripObj.status == .processing {
                self.layoutState = .tripMinimunActivity
            } else {
                self.layoutState = .tripFullActivity
            }
        } else {
            self.isShouldUpdateActivityLayout = true
            self.layoutState = .minimal

            // Reset data
            self.mapView.resetAllData()

            // Trigger location
            self.mapViewModel.input.startUpdateLocationTriggerPublisher.onNext(true)
        }
    }

    fileprivate func handleLayoutAndData(_ tripObj: TripObj) {

        // Layout
        self.updateLayoutWithTrip(tripObj)

        // Trip
        self.updateTripActivityView(tripObj)
    }

    fileprivate func updateTripActivityView(_ tripObj: TripObj) {

        Logger.info("Trip Obj = \(tripObj)")

        // Stop if unknown
        guard tripObj.status != .unknown else { return }

        // Update
        self.tripActivityView.updateData(tripObj)

        // Remove destination
        if self.isShouldUpdateActivityLayout {
            self.isShouldUpdateActivityLayout = false
            self.mapViewModel.input.didSelectPlaceObjPublisher.onNext(nil)
        }

        // Update map
        self.mapView.updateCurrentTripLayout(tripObj)

        // Get Route
        self.mapViewModel.input.routeForCurrentTripPublisher.onNext(tripObj)
        self.mapViewModel.output.routeCurrentTrip
            .drive(onNext: {[weak self] (route) in
                guard let `self` = self else { return }
                self.mapView.drawVisbileRoute(route)
            })
            .addDisposableTo(self.disposeBag)
    }
}

// MARK: - SearchBarViewDelegate
extension MapViewController: SearchBarViewDelegate {

    func searchBar(_ sender: SearchBarView, layoutStateDidChanged state: MapViewLayoutState) {
        self.layoutState = state
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
        self.mapViewModel.input.didSelectPlaceObjPublisher.onNext(placeObj)

        // Update layout
        self.layoutState = .productSelection
    }
}

extension MapViewController: PaymentMethodsControllerDelegate {

    func paymentMethodsControllerShouldDismiss(_ sender: PaymentMethodsController) {
        guard let controller = self.paymentMethodController else { return }
        self.dismissViewController(controller)
        self.paymentMethodController = nil
    }
}

extension MapViewController: TripActivityViewDelegate {

    func tripActivityViewShouldCancelCurrentTrip(_ sender: TripActivityView) {
        self.uberViewModel.input.cancelCurrentTripPublisher.onNext()
    }
}
