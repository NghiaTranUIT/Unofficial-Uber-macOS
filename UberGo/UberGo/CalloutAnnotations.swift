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
    fileprivate var destinationObj: PlaceObj?
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

        if let destObj = destinationObj {
            addressLbl.stringValue = destObj.name ?? ""
        }
    }

    // MARK: - Public
    public func setupCallout(mode: CalloutAnnotationsLayoutMode, timeObj: TimeEstimateObj?, destinationObj: PlaceObj?) {
        layoutMode = mode
        self.timeObj = timeObj
        self.destinationObj = destinationObj

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
