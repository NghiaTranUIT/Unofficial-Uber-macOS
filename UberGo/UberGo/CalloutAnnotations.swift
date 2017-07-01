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

        self.initCommon()
        self.setupLayoutMode(layoutMode)
        self.setupData()
    }

    fileprivate func setupLayoutMode(_ mode: CalloutAnnotationsLayoutMode) {
        switch mode {
        case .withTimeEstimation:
            self.timeContainerViewWidth.constant = 36
            self.view.layoutSubtreeIfNeeded()
        case .noTimeEstimation:
            self.timeContainerViewWidth.constant = 0
            self.view.layoutSubtreeIfNeeded()
        }
    }

    fileprivate func setupData() {

        guard let timeObj = self.timeObj else { return }
        self.timeEstimateLbl.stringValue = "\(timeObj.estimate ?? 5)"

        guard let destObj = self.destinationObj else { return }
        self.addressLbl.stringValue = destObj.address ?? ""
    }

    // MARK: - Public
    public func setupCallout(mode: CalloutAnnotationsLayoutMode, timeObj: TimeEstimateObj?, destinationObj: PlaceObj?) {
        self.layoutMode = mode
        self.timeObj = timeObj
        self.destinationObj = destinationObj

        // Relayout if view hasn't loaded yet
        if isViewLoaded {
            self.setupLayoutMode(layoutMode)
            self.setupData()
        }
    }
}

// MARK: - Private
extension CalloutAnnotations {

    fileprivate func initCommon() {
        self.view.backgroundColor = NSColor.white
    }
}
