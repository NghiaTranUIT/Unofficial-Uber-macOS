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

enum MainLayoutState {
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
    fileprivate lazy var tripActivityView: TripActivityView = self.lazyInitTripActivityView()
    fileprivate lazy var errorAlertView: UberAlertView = self.lazyInitErrorAlertView()
    fileprivate lazy var menuView: MenuView = self.lazyInitMenuView()

    // MARK: - Controller
    fileprivate lazy var mapController: MapViewController = self.lazyInitMapViewController()
    fileprivate lazy var searchController: SearchController = self.lazyInitSearchController()
    fileprivate lazy var uberController: UberController = self.lazyInitUberController()

    // MARK: - Variable
    fileprivate var coordinator: ViewModelCoordinatorProtocol!
    fileprivate var searchViewModel: SearchViewModelProtocol!

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
    fileprivate var _layoutState: MainLayoutState = .minimal {
        didSet {
            updateLayoutState(_layoutState)
        }
    }
    public fileprivate(set) var layoutState: MainLayoutState {
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
        controller.coordinator = coordinator
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

    override func viewDidAppear() {
        super.viewDidAppear()
    }

    deinit {
        NotificationCenter.removeAllObserve(self)
    }

    fileprivate func setupLayout() {
        menuView.configureLayout(menuContainerView)
        mapController.configureContainerController(self, containerView: mapContainerView)
        searchController.configureContainerController(self, containerView: mapContainerView)
    }

    fileprivate func binding() {

        // Trigger Get location
        mapController.startUpdateLocation()

        // Force load Uber data
        UberAuth.share.currentUser?.reloadUberDataPublisher.onNext()
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
        uberController.requestSurgeUber(with: url)
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
        mapController.selectPlace(nil)
    }
}

// MARK: - Private
extension MainViewController {

    fileprivate func initCommon() {
        view.backgroundColor = NSColor.white
        exitNavigateBtn.alphaValue = 0
        bottomBarView.backgroundColor = NSColor.black
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
        let controller = MapViewController.buildController(coordinator.mapViewModel)
        controller.delegate = self
        return controller
    }

    fileprivate func lazyInitUberController() -> UberController {
        let controller = UberController.buildController(coordinator.uberViewModel)
        controller.delegate = self
        return controller
    }
}

// MARK: - Layout
extension MainViewController {

    fileprivate func updateLayoutState(_ state: MainLayoutState) {

        // Update state to sub-views
        searchController.updateState(state)

        // Remove if need
        tripActivityView.removeFromSuperview()
        uberController.removeFromSuperview()

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

    fileprivate func preferredHeight(_ state: MainLayoutState) -> CGFloat {
        switch state {
        case .searchFullScreen, .expand, .minimal:
            return 480

        case .productSelection:
            uberController.configureLayout(bottomBarView)
            return 804

        case .tripFullActivity:
            if tripActivityView.superview == nil {
                tripActivityView.configureLayout(bottomBarView)
            }
            return 480 + 324

        case .tripMinimunActivity:
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
        tripObj.isValidTrip ?
            updateLayoutWithValidTrip(tripObj) : updateLayoutWithInvalidTrip()
    }

    private func updateLayoutWithValidTrip(_ tripObj: TripObj) {
        layoutState = tripObj.status == .processing ? .tripMinimunActivity : .tripFullActivity
    }

    private func updateLayoutWithInvalidTrip() {
        isShouldUpdateActivityLayout = true
        layoutState = .minimal
        mapController.resetAllData()
        mapController.startUpdateLocation()
    }

    fileprivate func updateLayoutForTrip(_ tripObj: TripObj) {

        // Layout
        updateLayoutWithTrip(tripObj)
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
            mapController.selectPlace(nil)
        }

        // Update map
        mapController.updateCurrentTripLayout(tripObj)

        // Get Route
        mapController.requestRoute(for: tripObj)
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
        uberController.cancelCurrentTrip()
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

    func shouldUpdateLayoutState(_ newState: MainLayoutState) {
        layoutState = newState
    }

    func didSelectPlace(_ placeObj: PlaceObj) {
        mapController.selectPlace(placeObj)
    }
}

extension MainViewController: MapViewControllerDelegate {

    func shouldRequestEstimateTrip(to data: UberRequestTripData?) {
        uberController.requestEstimateTrip(data)

        // Reset if need
        if data == nil {
            self.searchController.resetTextSearch()
        }
    }
}

// MARK: - UberControllerDelegate
extension MainViewController: UberControllerDelegate {

    func presentProductDetailController(_ product: ProductObj) {

        if productDetailController == nil {
            let controller = ProductDetailController(nibName: "ProductDetailController", bundle: nil)!
            controller.delegate = self
            controller.configureController(with: product)
            productDetailController = controller
        }

        // Present
        presentViewControllerAsSheet(productDetailController!)
    }

    func updateLayout(_ layout: MainLayoutState) {
        layoutState = layout
    }

    func presentSurgeHrefController(_ surge: SurgePriceObj) {
        Logger.info("SHOW CONFIRMATION = \(surge.surgeConfirmationHref ?? "")")
        showSurgeHrefView(surge)
    }

    func updateTripLayout(_ tripObj: TripObj) {
        updateLayoutForTrip(tripObj)
    }

    func resetMap() {
        mapController.selectPlace(nil)
        mapController.resetAllData()
        mapController.startUpdateLocation()
    }

    func drawRoute(with placeObj: PlaceObj) {
        mapController.addDestination(placeObj)
        mapController.requestRoute(to: placeObj)
    }
}
