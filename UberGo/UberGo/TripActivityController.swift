//
//  TripActivityController.swift
//  UberGo
//
//  Created by Nghia Tran on 10/31/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa
import UberGoCore

protocol TripActivityControllerDelegate: class {

    func tripActivityShouldCancelTrip()
}

class TripActivityController: NSViewController {

    // MARK: - Variable
    public weak var delegate: TripActivityControllerDelegate?

    // MARK: - View
    fileprivate lazy var activityView: TripActivityView = self.lazyInitTripActivityView()

    // MARK: - Init
    class func buildController() -> TripActivityController {
        return TripActivityController(nibName: NSNib.Name(rawValue: "TripActivityController"), bundle: nil)
    }

    // MARK: - View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        activityView.configureLayout(view)
    }

    // MARK: - Public
    public func removeFromSuperview() {
        removeFromParentViewController()
        view.removeFromSuperview()
    }

    public func configureChildController(_ container: NSView, parent: NSViewController) {
        guard view.superview == nil else {
            return
        }
        parent.addChildViewController(self)
        container.addSubview(view)
        view.edges(to: container)
    }

    public func update(_ tripObj: TripObj) {
        activityView.updateData(tripObj)
    }
}

// MARK: - Private
extension TripActivityController {

    fileprivate func lazyInitTripActivityView() -> TripActivityView {
        let uberView = TripActivityView.viewFromNib(with: BundleType.app)!
        uberView.delegate = self
        return uberView
    }
}

// MARK: - TripActivityViewDelegate
extension TripActivityController: TripActivityViewDelegate {

    func tripActivityViewShouldCancelCurrentTrip(_ sender: TripActivityView) {
        delegate?.tripActivityShouldCancelTrip()
    }
}
