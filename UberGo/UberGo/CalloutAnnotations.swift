//
//  CalloutAnnotations.swift
//  UberGo
//
//  Created by Nghia Tran on 6/29/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import UberGoCore

enum CalloutAnnotationsLayoutMode {
    case pickup
    case destination
}

class CalloutAnnotations: NSViewController {

    // MARK: - OUTLET
    @IBOutlet fileprivate weak var timeContainerViewWidth: NSLayoutConstraint!
    @IBOutlet fileprivate weak var timeEstimateLbl: NSTextField!
    @IBOutlet fileprivate weak var addressLbl: NSTextField!

    // MARK: - Variable
    fileprivate var timeObj: TimeEstimateObj?
    fileprivate var destinationObj: PlaceObj?
    fileprivate var layoutMode: CalloutAnnotationsLayoutMode = .pickup

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initCommon()
        self.setupLayout()
        self.setupData()
    }

    fileprivate func setupLayout() {
        switch layoutMode {
        case .pickup:
            self.timeContainerViewWidth.constant = 36
            self.view.layoutSubtreeIfNeeded()
        case .destination:
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
    }
}

// MARK: - Private
extension CalloutAnnotations {

    fileprivate func initCommon() {
        self.view.backgroundColor = NSColor.white
    }
}
