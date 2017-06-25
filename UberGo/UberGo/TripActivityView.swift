//
//  TripActivityView.swift
//  UberGo
//
//  Created by Nghia Tran on 6/25/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa

class TripActivityView: NSView {

    // MARK: - OUTLET

    // Status
    @IBOutlet fileprivate weak var statusLbl: NSTextField!
    @IBOutlet fileprivate weak var etaLbl: NSTextField!
    @IBOutlet fileprivate weak var dividerStatusLineView: NSView!

    // Driver
    @IBOutlet fileprivate weak var driverContainerView: NSView!
    @IBOutlet fileprivate weak var driverAvatarImageView: NSImageView!
    @IBOutlet fileprivate weak var driverNameLbl: NSTextField!
    @IBOutlet fileprivate weak var driverRatingLbl: NSTextField!
    @IBOutlet fileprivate weak var driverModelLbl: NSTextField!
    @IBOutlet fileprivate weak var driverLicensePlateLbl: NSButton!
    @IBOutlet fileprivate weak var contactDriverBtn: NSButton!
    @IBOutlet fileprivate weak var cancelTripBtn: NSButton!

    // Trip
    @IBOutlet fileprivate weak var activityContainerView: NSView!
    @IBOutlet fileprivate weak var destinationContainerView: NSView!
    @IBOutlet fileprivate weak var destinationLbl: NSTextField!
    @IBOutlet fileprivate weak var changeDestinationBtn: NSButton!
    @IBOutlet fileprivate weak var dividerActiviyView: NSView!
    @IBOutlet fileprivate weak var timeContainerView: NSView!
    @IBOutlet fileprivate weak var arrvialTimeLbl: NSTextField!
    @IBOutlet fileprivate weak var shareStatusBtn: NSButton!

    // MARK: - Variable


    // MARK: - Public
    func configureLayout(_ parentView: NSView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(self)

        let top = NSLayoutConstraint(item: self,
                                     attribute: .top,
                                     relatedBy: .equal,
                                     toItem: parentView,
                                     attribute: .top,
                                     multiplier: 1,
                                     constant: 0)
        let left = NSLayoutConstraint(item: self,
                                      attribute: .left,
                                      relatedBy: .equal,
                                      toItem: parentView,
                                      attribute: .left,
                                      multiplier: 1,
                                      constant: 0)
        let right = NSLayoutConstraint(item: self,
                                       attribute: .right,
                                       relatedBy: .equal,
                                       toItem: parentView,
                                       attribute: .right,
                                       multiplier: 1,
                                       constant: 0)
        let bottom = NSLayoutConstraint(item: self,
                                        attribute: .bottom,
                                        relatedBy: .equal,
                                        toItem: parentView, attribute: .bottom,
                                        multiplier: 1,
                                        constant: 0)
        parentView.addConstraints([top, left, right, bottom])
    }

}

// MARK: - XIBInitializable
extension TripActivityView: XIBInitializable {
    typealias XibType = TripActivityView
}
