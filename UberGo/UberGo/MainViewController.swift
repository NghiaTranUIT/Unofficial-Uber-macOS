//
//  MainViewController.swift
//  UberGo
//
//  Created by Nghia Tran on 10/31/17.
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
    case searchFullScreen
    case productSelection
    case tripFullActivity
    case tripMinimunActivity
}

class MainViewController: BaseViewController {

    // MARK: - OUTLET
    @IBOutlet fileprivate weak var exitNavigateBtn: NSButton!
    @IBOutlet fileprivate weak var mapContainerView: NSView!
    @IBOutlet fileprivate weak var bottomBarView: NSView!
    @IBOutlet fileprivate weak var containerViewHeight: NSLayoutConstraint!
    @IBOutlet fileprivate weak var menuContainerView: NSView!
    @IBOutlet fileprivate weak var menuContainerViewOffset: NSLayoutConstraint!

    // MARK: - View
    fileprivate lazy var mapView: UberMapView = self.lazyInitUberMapView()
    fileprivate lazy var selectUberView: RequestUberView = self.lazyInitRequestUberView()
    fileprivate lazy var tripActivityView: TripActivityView = self.lazyInitTripActivityView()
    fileprivate lazy var errorAlertView: UberAlertView = self.lazyInitErrorAlertView()
    fileprivate lazy var menuView: MenuView = self.lazyInitMenuView()

    // MARK: - Controller
    fileprivate lazy var mapViewController: MapViewController = self.lazyInitMapViewController()
    fileprivate lazy var searchController: SearchController = self.lazyInitSearchController()

    // MARK: - Variable
    fileprivate var mapViewModel: MapViewModelProtocol!
    fileprivate var searchViewModel: SearchViewModelProtocol!
    fileprivate var uberViewModel: UberServiceViewModelProtocol!

    fileprivate var isFirstTime = true
    fileprivate var isMenuOpened = false {
        didSet {
            self.handleMenuLayout()
        }
    }
    fileprivate lazy var webController: WebViewController = self.lazyInitWebController()
    fileprivate var paymentMethodController: PaymentMethodsController?
    fileprivate var productDetailController: ProductDetailController?
    fileprivate var isShouldUpdateActivityLayout = true

    // Layout State
    fileprivate var _layoutState: MapViewLayoutState = .minimal {
        didSet {
            updateLayoutState(_layoutState)
        }
    }
    public fileprivate(set) var layoutState: MapViewLayoutState {
        get {
            return _layoutState
        }
        set {
            guard newValue != _layoutState else { return }
            _layoutState = newValue
        }
    }

    // MARK: - Init
    public class func buildController(_ coordinator: ViewModelCoordinatorProtocol) -> MainViewController {
        let controller = MainViewController(nibName: "MainViewController", bundle: nil)!
        controller.mapViewModel = coordinator.mapViewModel
        controller.uberViewModel = coordinator.uberViewModel
        controller.searchViewModel = coordinator.searchViewModel
        return controller
    }

    // MARK: - View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Common
        initCommon()

        // Binding
        binding()
        notificationBinding()

        // Setup Layout
        setupLayout()
    }

    public func configureBinding(coordinator: ViewModelCoordinator) {
        uberViewModel = coordinator.uberViewModel
        mapViewModel = coordinator.mapViewModel
        searchViewModel = coordinator.searchViewModel
    }

    override func viewDidAppear() {
        super.viewDidAppear()
    }

    deinit {
        NotificationCenter.removeAllObserve(self)
    }

    fileprivate func setupLayout() {
        menuView.configureLayout(menuContainerView)
        searchController.configureContainerController(self, containerView: mapContainerView)
        mapView.setupViewModel(mapViewModel)
    }

    fileprivate func binding() {
        selectUberView.viewModel = uberViewModel

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
                    self.uberViewModel.input.requestEstimateTripPublish.onNext(data)
                } else {
                    self.uberViewModel.input.requestEstimateTripPublish.onNext(nil)
                    self.searchController.resetTextSearch()
                    self.mapView.addDestinationPlaceObj(nil)
                }
            })
            .addDisposableTo(disposeBag)

        // Fetch route navigation
        uberViewModel.output.requestUberEstimationSuccessDriver
            .drive(onNext: { [weak self] result in
                guard let `self` = self else { return }

                // Handle result
                switch result {
                case .success(let data):
                    self.mapView.addDestinationPlaceObj(data.to)
                    self.mapViewModel.input.routeToDestinationPublisher.onNext(data.to)
                default:
                    break
                }

            })
            .addDisposableTo(disposeBag)

        // Request Uber service
        uberViewModel.output.availableGroupProductsDriver
            .drive(onNext: {[weak self] (result) in
                guard let `self` = self else { return }

                // Stop loader

                // Handle result
                switch result {
                case .success(let groups):
                    self.layoutState = .productSelection
                    self.selectUberView.updateAvailableGroupProducts(groups)
                case .error(let error):
                    Logger.error("ERROR = \(error)")
                    NotificationCenter.postNotificationOnMainThreadType(.showFriendlyErrorAlert,
                                                                        object: error,
                                                                        userInfo: nil)
                }
            })
            .addDisposableTo(disposeBag)

        // Show or hide Bottom bar
        uberViewModel.output.isLoadingDriver
            .drive(onNext: { isLoading in
                Logger.info("isLoading Available Products = \(isLoading)")
            })
            .addDisposableTo(disposeBag)

        // Show href
        uberViewModel.output.showSurgeHrefDriver
            .drive(onNext: {[weak self] surgeObj in
                guard let `self` = self else { return }
                Logger.info("SHOW CONFIRMATION = \(surgeObj.surgeConfirmationHref ?? "")")
                self.showSurgeHrefView(surgeObj)
            })
            .addDisposableTo(disposeBag)

        // Trip
        uberViewModel.output.normalTripDriver
            .drive(onNext: {[weak self] (createTripObj) in
                guard let `self` = self else { return }

                Logger.info("Start Request Normal TRIP = \(createTripObj)")

                // Update layout
                self.layoutState = .tripMinimunActivity

                // Trigger to start Timer
                self.uberViewModel.input.triggerCurrentTripPublisher.onNext()
            })
            .addDisposableTo(disposeBag)

        // Current Trip Status
        uberViewModel.output.currentTripStatusDriver
            .drive(onNext: {[weak self] result in
                guard let `self` = self else { return }

                // Update
                switch result {
                case .success(let tripObj):
                    self.handleLayoutAndData(tripObj)
                case .error(let error):
                    Logger.error(error)
                    self.handleLayoutAndData(TripObj.invalidDummyTrip())
                }
                }, onCompleted: {
                    Logger.info("On Completed")
            }, onDisposed: {
                Logger.info("On Disposed")
            })
            .addDisposableTo(disposeBag)

        // Get first check Trip Status
        uberViewModel.input.triggerCurrentTripPublisher.onNext()

        // Cancel
        uberViewModel.output.resetMapDriver
            .drive(onNext: {[weak self] _ in
                guard let `self` = self else { return }

                self.layoutState = .minimal

                // Reset
                self.mapViewModel.input.selectPlaceObjPublisher.onNext(nil)
                self.uberViewModel.input.requestEstimateTripPublish.onNext(nil)

                // Reset data
                self.mapView.resetAllData()

                // Trigger location
                self.mapViewModel.input.startUpdateLocationTriggerPublisher.onNext(true)
            })
            .addDisposableTo(disposeBag)
    }

    fileprivate func notificationBinding() {
        NotificationCenter.observeNotificationType(.showPaymentMethodsView,
                                                   observer: self,
                                                   selector: #selector(showPaymentMethodView(noti:)),
                                                   object: nil)
        NotificationCenter.observeNotificationType(.handleSurgeCallback,
                                                   observer: self,
                                                   selector: #selector(handleSurgeCallback(noti:)),
                                                   object: nil)
        NotificationCenter.observeNotificationType(.showFriendlyErrorAlert,
                                                   observer: self,
                                                   selector: #selector(showFriendlyErrorAlert(noti:)),
                                                   object: nil)
        NotificationCenter.observeNotificationType(.openCloseMenu,
                                                   observer: self,
                                                   selector: #selector(handleMenuLayoutNotification),
                                                   object: nil)

    }

    func showSurgeHrefView(_ surgeObj: SurgePriceObj) {
        webController.data = surgeObj
        presentViewControllerAsSheet(webController)
    }

    @objc func showPaymentMethodView(noti: Notification) {
        let controller = PaymentMethodsController(nibName: "PaymentMethodsController", bundle: nil)!
        controller.delegate = self
        presentViewControllerAsSheet(controller)
        paymentMethodController = controller
    }

    @objc func handleSurgeCallback(noti: Notification) {
        guard let event = noti.object as? NSAppleEventDescriptor else { return }
        guard let url = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue else {
            return
        }

        // Hide
        dismissViewController(webController)

        // Get
        uberViewModel.input.requestUberWithSurgeIDPublisher.onNext(url)
    }

    @objc func showFriendlyErrorAlert(noti: Notification) {
        guard let error = noti.object as? NSError else { return }
        errorAlertView.showError(error, view: self.view)
    }

    @objc func handleMenuLayoutNotification() {
        isMenuOpened = !isMenuOpened
    }

    @IBAction func exitNavigateBtnOnTapped(_ sender: Any) {

        // Minimal
        layoutState = .minimal

        // Remove current
        mapViewModel.input.selectPlaceObjPublisher.onNext(nil)
    }
}

// MARK: - Private
extension MainViewController {

    fileprivate func initCommon() {
        view.backgroundColor = NSColor.white
        exitNavigateBtn.alphaValue = 0
        bottomBarView.backgroundColor = NSColor.black
    }

    fileprivate func lazyInitUberMapView() -> UberMapView {
        let map = UberMapView(frame: mapContainerView.bounds)
        map.uberMapDelegate = self
        map.configureLayout(mapContainerView)
        return map
    }

    fileprivate func lazyInitRequestUberView() -> RequestUberView {
        let uberView = RequestUberView.viewFromNib(with: BundleType.app)!
        uberView.delegate = self
        return uberView
    }

    fileprivate func lazyInitSearchController() -> SearchController {
        let controller = SearchController(viewModel: searchViewModel)!
        controller.delegate = self
        return controller
    }

    fileprivate func lazyInitTripActivityView() -> TripActivityView {
        let uberView = TripActivityView.viewFromNib(with: BundleType.app)!
        uberView.delegate = self
        return uberView
    }

    fileprivate func lazyInitWebController() -> WebViewController {
        return WebViewController.webviewControllerWith(.surgeConfirmation)
    }

    fileprivate func lazyInitErrorAlertView() -> UberAlertView {
        return UberAlertView.viewFromNib(with: BundleType.app)!
    }

    fileprivate func lazyInitMenuView() -> MenuView {
        return MenuView.viewFromNib(with: BundleType.app)!
    }

    fileprivate func lazyInitMapViewController() -> MapViewController {
        return MapViewController.buildController(mapViewModel)
    }
}

// MARK: - Layout
extension MainViewController {

    fileprivate func updateLayoutState(_ state: MapViewLayoutState) {

        // Update state to sub-views
        searchController.updateState(state)

        // Remove if need
        tripActivityView.removeFromSuperview()
        selectUberView.removeFromSuperview()

        // Layout
        let newHeight = preferredHeight(state)

        // Animate
        containerViewHeight.constant = newHeight
        view.layoutSubtreeIfNeeded()

        // Fade in
        NSAnimationContext.defaultAnimate({ _ in
            self.exitNavigateBtn.alphaValue = state == .productSelection ? 1 : 0
        })
    }

    fileprivate func preferredHeight(_ state: MapViewLayoutState) -> CGFloat {
        switch state {
        case .searchFullScreen, .expand, .minimal:
            return 480

        case .productSelection:

            // Add
            if selectUberView.superview == nil {
                selectUberView.configureLayout(bottomBarView)
            }

            return 804

        case .tripFullActivity:

            // Add
            if tripActivityView.superview == nil {
                tripActivityView.configureLayout(bottomBarView)
            }

            return 480 + 324

        case .tripMinimunActivity:

            // Add
            if tripActivityView.superview == nil {
                tripActivityView.configureLayout(bottomBarView)
            }
            return 480 + 70
        }
    }

    fileprivate func handleMenuLayout() {
        menuContainerViewOffset.constant = isMenuOpened ? 0 : -282
        menuContainerView.layoutSubtreeIfNeeded()
    }
}

// MARK: - Activity View
extension MainViewController {

    fileprivate func updateLayoutWithTrip(_ tripObj: TripObj) {

        // Reset layout if there is no trip
        if tripObj.isValidTrip {
            if tripObj.status == .processing {
                layoutState = .tripMinimunActivity
            } else {
                layoutState = .tripFullActivity
            }
        } else {
            isShouldUpdateActivityLayout = true
            layoutState = .minimal

            // Reset data
            mapView.resetAllData()

            // Trigger location
            mapViewModel.input.startUpdateLocationTriggerPublisher.onNext(true)
        }
    }

    fileprivate func handleLayoutAndData(_ tripObj: TripObj) {

        // Layout
        updateLayoutWithTrip(tripObj)

        // Trip
        updateTripActivityView(tripObj)
    }

    fileprivate func updateTripActivityView(_ tripObj: TripObj) {

        Logger.info("Trip Obj = \(tripObj)")

        // Stop if unknown
        guard tripObj.status != .unknown else { return }

        // Update
        tripActivityView.updateData(tripObj)

        // Remove destination
        if isShouldUpdateActivityLayout {
            isShouldUpdateActivityLayout = false
            mapViewModel.input.selectPlaceObjPublisher.onNext(nil)
        }

        // Update map
        mapView.updateCurrentTripLayout(tripObj)

        // Get Route
        mapViewModel.input.routeForCurrentTripPublisher.onNext(tripObj)
    }
}

extension MainViewController: PaymentMethodsControllerDelegate {

    func paymentMethodsControllerShouldDismiss(_ sender: PaymentMethodsController) {
        guard let controller = paymentMethodController else { return }
        dismissViewController(controller)
        paymentMethodController = nil
    }
}

extension MainViewController: TripActivityViewDelegate {

    func tripActivityViewShouldCancelCurrentTrip(_ sender: TripActivityView) {
        uberViewModel.input.cancelCurrentTripPublisher.onNext()
    }
}

extension MainViewController: UberMapViewDelegate {
    func uberMapViewTimeEstimateForOriginAnnotation() -> TimeEstimateObj? {
        return uberViewModel.output.selectedProduct.value?.estimateTime
    }
}

extension MainViewController: RequestUberViewDelegate {

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

extension MainViewController: ProductDetailControllerDelegate {

    func productDetailControllerShouldDimiss() {
        dismissViewController(productDetailController!)
        productDetailController = nil
    }
}

// MARK: - SearchControllerDelegate
extension MainViewController: SearchControllerDelegate {

    func shouldUpdateLayoutState(_ newState: MapViewLayoutState) {
        layoutState = newState
    }

    func didSelectPlace(_ placeObj: PlaceObj) {
        mapViewModel.input.selectPlaceObjPublisher.onNext(placeObj)
    }
}
