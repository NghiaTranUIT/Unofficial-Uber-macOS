//
//  CalloutAnnotations.swift
//  UberGo
//
//  Created by Nghia Tran on 6/29/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import UberGoCore

enum CalloutAnnotationsLayoutMode {
    case noTimeEstimation
    case withTimeEstimation
}

class CalloutAnnotations: NSViewController {

    // MARK: - OUTLET
    @IBOutlet fileprivate weak var timeContainerViewWidth: NSLayoutConstraint!
    @IBOutlet fileprivate weak var timeEstimateLbl: NSTextField!
    @IBOutlet fileprivate weak var addressLbl: NSTextField!

    // MARK: - Variable
    fileprivate var timeETA: String?
    fileprivate var calloutTitle: String?
    fileprivate var layoutMode: CalloutAnnotationsLayoutMode = .noTimeEstimation

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()

        initCommon()
        setupLayoutMode(layoutMode)
        setupData()
    }

    fileprivate func setupLayoutMode(_ mode: CalloutAnnotationsLayoutMode) {
        switch mode {
        case .withTimeEstimation:
            timeContainerViewWidth.constant = 36
            view.layoutSubtreeIfNeeded()
        case .noTimeEstimation:
            timeContainerViewWidth.constant = 0
            view.layoutSubtreeIfNeeded()
        }
    }

    fileprivate func setupData() {
        timeEstimateLbl.stringValue = timeETA ?? "-"
        addressLbl.stringValue = calloutTitle ?? "Unknown"
    }

    // MARK: - Public
    public func setupCallout(mode: CalloutAnnotationsLayoutMode, timeETA: String?, calloutTitle: String?) {
        self.timeETA = timeETA
        self.calloutTitle = calloutTitle

        // Layout mode
        layoutMode = mode
        if timeETA == nil {
            layoutMode = .noTimeEstimation
        }

        // Relayout if view hasn't loaded yet
        if isViewLoaded {
            setupLayoutMode(layoutMode)
            setupData()
        }
    }

    public func setupPickupPointCallout(_ pickup: PickupPointObj) {
        setupCallout(mode: .withTimeEstimation, timeETA: pickup.prettyETA, calloutTitle: pickup.name ?? "Pickup point")
    }
}

// MARK: - Private
extension CalloutAnnotations {

    fileprivate func initCommon() {
        view.backgroundColor = NSColor.white
    }
}
