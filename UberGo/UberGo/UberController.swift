//
//  UberController.swift
//  UberGo
//
//  Created by Nghia Tran on 10/31/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa
import RxCocoa
import RxSwift
import UberGoCore

protocol UberControllerDelegate: class {

    func presentProductDetailController(_ product: ProductObj)
    func presentSurgeHrefController(_ surge: SurgePriceObj)
    func updateLayout(_ layout: MainLayoutState)
    func updateTripLayout(_ tripObj: TripObj)
    func resetMap()
    func drawRoute(with placeObj: PlaceObj)
}

class UberController: NSViewController {

    // MARK: - Variable
    fileprivate lazy var selectUberView: RequestUberView = self.lazyInitRequestUberView()
    fileprivate let disposeBag = DisposeBag()
    public weak var delegate: UberControllerDelegate?

    // MARK: - View Model
    fileprivate var uberViewModel: UberServiceViewModelProtocol!

    // MARK: - Init
    public class func buildController(_ uberViewModel: UberServiceViewModelProtocol) -> UberController {
        let controller = UberController(nibName: NSNib.Name(rawValue: "UberController"), bundle: nil)
        controller.uberViewModel = uberViewModel
        return controller
    }

    // MARK: - View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        binding()
    }

    // MARK: - Private
    private func binding() {
        selectUberView.viewModel = uberViewModel

        // Fetch route navigation
        uberViewModel.output.requestUberEstimationSuccessDriver
            .drive(onNext: { [weak self] result in
                guard let `self` = self else { return }
                guard let place = result.result?.to else { return }

                // Draw Route
                self.delegate?.drawRoute(with: place)
            })
            .disposed(by: disposeBag)

        // Request Uber service
        uberViewModel.output.availableGroupProductsDriver
            .drive(onNext: {[weak self] (result) in
                guard let `self` = self else { return }

                switch result {
                case .success(let groups):
                    self.delegate?.updateLayout(.productSelection)
                    self.selectUberView.updateAvailableGroupProducts(groups)
                case .error(let error):
                    Logger.error("ERROR = \(error)")
                    NotificationCenter.postNotificationOnMainThreadType(.showFriendlyErrorAlert,
                                                                        object: error,
                                                                        userInfo: nil)
                }
            })
            .disposed(by: disposeBag)

        // Show or hide Bottom bar
        uberViewModel.output.isLoadingDriver
            .drive(onNext: { isLoading in
                Logger.info("isLoading Available Products = \(isLoading)")
            })
            .disposed(by: disposeBag)

        // Show href
        uberViewModel.output.showSurgeHrefDriver
            .drive(onNext: {[weak self] surgeObj in
                guard let `self` = self else { return }
                self.delegate?.presentSurgeHrefController(surgeObj)
            })
            .disposed(by: disposeBag)

        // Trip
        uberViewModel.output.normalTripDriver
            .drive(onNext: {[weak self] (createTripObj) in
                guard let `self` = self else { return }

                Logger.info("Start Request Normal TRIP = \(createTripObj)")

                // Update layout
                self.delegate?.updateLayout(.tripMinimunActivity)

                // Trigger to start Timer
                self.uberViewModel.input.triggerCurrentTripPublisher.onNext(())
            })
            .disposed(by: disposeBag)

        // Current Trip Status
        uberViewModel.output.currentTripStatusDriver
            .drive(onNext: {[weak self] result in
                guard let `self` = self else { return }

                switch result {
                case .success(let tripObj):
                    self.delegate?.updateTripLayout(tripObj)
                case .error(let error):
                    Logger.error(error)
                    self.delegate?.updateTripLayout(TripObj.invalidDummyTrip())
                }
            })
            .disposed(by: disposeBag)

        // Get first check Trip Status
        uberViewModel.input.triggerCurrentTripPublisher.onNext(())

        // Cancel
        uberViewModel.output.resetMapDriver
            .drive(onNext: {[weak self] _ in
                guard let `self` = self else { return }

                self.uberViewModel.input.requestEstimateTripPublish.onNext(nil)
                self.delegate?.updateLayout(.minimal)
                self.delegate?.resetMap()
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Public
    public func requestEstimateTrip(_ data: UberRequestTripData?) {
        uberViewModel.input.requestEstimateTripPublish.onNext(data)
    }

    public func removeFromSuperview() {
        removeFromParentViewController()
        view.removeFromSuperview()
    }

    public func configureLayout(_ parentView: NSView) {
        if selectUberView.superview == nil {
            selectUberView.configureLayout(parentView)
        }
    }

    public func cancelCurrentTrip() {
        uberViewModel.input.cancelCurrentTripPublisher.onNext(())
    }

    public func requestSurgeUber(with surgeURL: String) {
        uberViewModel.input.requestUberWithSurgeIDPublisher.onNext(surgeURL)
    }
}

// MARK: - Common
extension UberController {

    fileprivate func lazyInitRequestUberView() -> RequestUberView {
        let uberView = RequestUberView.viewFromNib(with: BundleType.app)!
        uberView.delegate = self
        return uberView
    }
}

// MARK: - RequestUberViewDelegate
extension UberController: RequestUberViewDelegate {

    func requestUberViewShouldShowProductDetail(_ productObj: ProductObj) {
        self.delegate?.presentProductDetailController(productObj)
    }
}
