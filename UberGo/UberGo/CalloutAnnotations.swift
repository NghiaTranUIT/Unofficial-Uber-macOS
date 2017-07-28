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
    fileprivate var timeObj: TimeEstimateObj?
    fileprivate var placeObj: PlaceObj?
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

        if let timeObj = timeObj {
            timeEstimateLbl.stringValue = "\(timeObj.prettyEstimateTime)"
        }

        if let destObj = placeObj {
            addressLbl.stringValue = destObj.name
        }
    }

    // MARK: - Public
    public func setupCallout(mode: CalloutAnnotationsLayoutMode, timeObj: TimeEstimateObj?, placeObj: PlaceObj?) {
        self.timeObj = timeObj
        self.placeObj = placeObj
        layoutMode = mode

        if timeObj == nil {
            layoutMode = .noTimeEstimation
        }

        // Relayout if view hasn't loaded yet
        if isViewLoaded {
            setupLayoutMode(layoutMode)
            setupData()
        }
    }
}

// MARK: - Private
extension CalloutAnnotations {

    fileprivate func initCommon() {
        view.backgroundColor = NSColor.white
    }
}
