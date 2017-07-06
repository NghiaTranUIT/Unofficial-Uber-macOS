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
    fileprivate lazy var searchCollectionView: SearchCollectionView = self.lazyInitSearchCollectionView()
    fileprivate lazy var selectUberView: RequestUberView = self.lazyInitRequestUberView()
    fileprivate lazy var tripActivityView: TripActivityView = self.lazyInitTripActivityView()
    fileprivate lazy var searchBarView: SearchBarView = self.lazyInitSearchBarView()

    @IBOutlet fileprivate weak var exitNavigateBtn: NSButton!
    @IBOutlet fileprivate weak var mapContainerView: NSView!
    @IBOutlet fileprivate weak var bottomBarView: NSView!
    @IBOutlet fileprivate weak var containerViewHeight: NSLayoutConstraint!

    // MARK: - Variable
    fileprivate var mapViewModel = MapViewModel()
    fileprivate let uberViewModel = UberServiceViewModel()

    fileprivate var isFirstTime = true
    fileprivate lazy var webController: WebViewController = self.lazyInitWebController()
    fileprivate var paymentMethodController: PaymentMethodsController?
    fileprivate var productDetailController: ProductDetailController?
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

        // View Model
        self.binding()
        searchBarView.setupViewModel(mapViewModel)
        searchCollectionView.setupViewModel(mapViewModel)
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

        // Selected Place
        self.mapViewModel.output.selectedPlaceObjDriver
            .drive(onNext: {[weak self] placeObj in
                guard let `self` = self else { return }

                // Draw
                self.mapView.addDestinationPlaceObj(placeObj)

                // Request Product + Estimate Uber
                if let placeObj = placeObj {
                    guard let currentLocation = self.mapViewModel.currentLocationVariable.value else { return }
                    let data = UberTripData(to: placeObj, from: currentLocation.coordinate)
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
        self.uberViewModel.output.isLoadingDriver
            .drive(onNext: { isLoading in
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
        self.webController.data = surgeObj
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
        self.mapView.uberMapDelegate = self
        self.mapView.configureLayout(self.mapContainerView, exitBtn: self.exitNavigateBtn)
    }

    fileprivate func lazyInitSearchBarView() -> SearchBarView {
        let searchView = SearchBarView.viewFromNib(with: BundleType.app)!
        searchView.delegate = self
        mapContainerView.addSubview(searchView, positioned: .below, relativeTo: exitNavigateBtn)
        searchView.configureView(with: mapContainerView)
        return searchView
    }

    fileprivate func lazyInitSearchCollectionView() -> SearchCollectionView {
        let collectionView = SearchCollectionView.viewFromNib(with: BundleType.app)!
        collectionView.delegate = self
        mapContainerView.addSubview(collectionView,
                                         positioned: .below,
                                         relativeTo: exitNavigateBtn)
        collectionView.configureView(parenView: mapContainerView, searchBarView: searchBarView)
        return collectionView
    }

    fileprivate func lazyInitRequestUberView() -> RequestUberView {
        let uberView = RequestUberView.viewFromNib(with: BundleType.app)!
        uberView.backgroundColor = NSColor.black
        uberView.delegate = self
        return uberView
    }

    fileprivate func lazyInitTripActivityView() -> TripActivityView {
        let uberView = TripActivityView.viewFromNib(with: BundleType.app)!
        uberView.backgroundColor = NSColor.black
        uberView.delegate = self
        return uberView
    }

    fileprivate func lazyInitWebController() -> WebViewController {
        return WebViewController.webviewControllerWith(.surgeConfirmation)
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

// MARK: - SearchCollectionViewDelegate
extension MapViewController: SearchCollectionViewDelegate {

    func searchCollectionViewDidSelectItem() {
        layoutState = .productSelection
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

extension MapViewController: UberMapViewDelegate {
    func uberMapViewTimeEstimateForOriginAnnotation() -> TimeEstimateObj? {
        return self.uberViewModel.output.selectedProduct.value?.estimateTime
    }
}

extension MapViewController: RequestUberViewDelegate {

    func requestUberViewShouldShowProductDetail(_ productObj: ProductObj) {
        if productDetailController == nil {
            let controller = ProductDetailController(nibName: "ProductDetailController", bundle: nil)!
            controller.delegate = self
            controller.configureController(with: productObj)
            productDetailController = controller
        }

        // Present
        presentViewControllerAsSheet(productDetailController!)
    }
}

extension MapViewController: ProductDetailControllerDelegate {

    func productDetailControllerShouldDimiss() {
        dismissViewController(productDetailController!)
        productDetailController = nil
    }
}
