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
    @IBOutlet fileprivate weak var statusLbl: UberTextField!
    @IBOutlet fileprivate weak var etaLbl: UberTextField!

    // Driver
    @IBOutlet fileprivate weak var driverContainerView: NSView!
    @IBOutlet fileprivate weak var driverAvatarImageView: NSImageView!
    @IBOutlet fileprivate weak var driverNameLbl: UberTextField!
    @IBOutlet fileprivate weak var driverRatingLbl: UberTextField!
    @IBOutlet fileprivate weak var driverModelLbl: UberTextField!
    @IBOutlet fileprivate weak var driverLicensePlateLbl: UberButton!
    @IBOutlet fileprivate weak var contactDriverBtn: UberButton!
    @IBOutlet fileprivate weak var cancelTripBtn: UberButton!

    // Trip
    @IBOutlet fileprivate weak var activityContainerView: NSView!
    @IBOutlet fileprivate weak var destinationContainerView: NSView!
    @IBOutlet fileprivate weak var destinationLbl: UberTextField!
    @IBOutlet fileprivate weak var changeDestinationBtn: UberButton!
    @IBOutlet fileprivate weak var dividerFirstView: NSView!
    @IBOutlet fileprivate weak var dividerSecondView: NSView!

    @IBOutlet fileprivate weak var timeContainerView: NSView!
    @IBOutlet fileprivate weak var arrvialTimeLbl: UberTextField!
    @IBOutlet fileprivate weak var shareStatusBtn: UberButton!

    @IBOutlet weak var paymentContainerView: NSView!

    // MARK: - Variable

    // MARK: - Init
    override func awakeFromNib() {
        super.awakeFromNib()

        self.initCommon()
    }

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

// MARK: - Private
extension TripActivityView {

    fileprivate func initCommon() {

        self.backgroundColor = NSColor.black
        self.driverContainerView.backgroundColor = NSColor.white
        self.activityContainerView.backgroundColor = NSColor.white
        self.destinationContainerView.backgroundColor = NSColor.white
        self.timeContainerView.backgroundColor = NSColor.white
        self.paymentContainerView.backgroundColor = NSColor.white
        
        self.contactDriverBtn.wantsLayer = true
        self.contactDriverBtn.layer?.borderWidth = 1
        self.contactDriverBtn.layer?.borderColor = NSColor(hexString: "#ededed").cgColor
        self.contactDriverBtn.setTitleColor(NSColor(hexString: "#235a92"))

        self.cancelTripBtn.wantsLayer = true
        self.cancelTripBtn.layer?.borderWidth = 1
        self.cancelTripBtn.layer?.borderColor = NSColor(hexString: "#ededed").cgColor
        self.cancelTripBtn.setTitleColor(NSColor(hexString: "#9e191e"))

        self.driverLicensePlateLbl.layer?.borderColor = NSColor(hexString: "#a4a5aa").cgColor
        self.driverLicensePlateLbl.layer?.borderWidth = 1

        self.dividerFirstView.backgroundColor = NSColor(hexString: "#ededed")
        self.dividerSecondView.backgroundColor = NSColor(hexString: "#ededed")

        // Kern
        self.statusLbl.setKern(2.0)
        self.etaLbl.setKern(1.4)
    }
}

// MARK: - XIBInitializable
extension TripActivityView: XIBInitializable {
    typealias XibType = TripActivityView
}
