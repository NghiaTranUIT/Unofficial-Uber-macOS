//
//  TripActivityView.swift
//  UberGo
//
//  Created by Nghia Tran on 6/25/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import UberGoCore

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
    @IBOutlet weak var paymentImageView: NSImageView!
    @IBOutlet weak var cardNumberLbl: UberTextField!

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
    
    public func updateData(_ tripObj: TripObj) {

        // Status
        self.updateStatus(tripObj)

        // ETA
        self.updateETA(tripObj)

        // Driver name 
        self.updateDriver(tripObj)

        // Vehicle
        self.updateVehicle(tripObj)

        // Destination ETA
        //self.arrvialTimeLbl.stringValue = tripObj.destination?.eta

        // Current Payment
        self.updatePayment()
    }

    // MARK: - Update Layout
    fileprivate func updateStatus(_ tripObj: TripObj) {

        // Name
        self.statusLbl.stringValue = tripObj.status.prettyValue
        self.statusLbl.setKern(2.0)

        // Enable - Disable
        if tripObj.status == .processing ||
            tripObj.status == .driverCanceled ||
            tripObj.status == .riderCanceled ||
            tripObj.status == .noDriversAvailable ||
            tripObj.status == .unknown {

            self.contactDriverBtn.isEnabled = false
            self.shareStatusBtn.isEnabled = false
            self.changeDestinationBtn.isEnabled = false
        }
        else {
            self.contactDriverBtn.isEnabled = true
            self.shareStatusBtn.isEnabled = true
            self.changeDestinationBtn.isEnabled = true
        }
    }

    fileprivate func updateETA(_ tripObj: TripObj) {
        self.etaLbl.isHidden = true
        if tripObj.status == .accepted {
            self.etaLbl.isHidden = false
            self.etaLbl.stringValue = "\(tripObj.pickup?.eta ?? 5) mins"
        } else if tripObj.status == .arriving {
            self.etaLbl.isHidden = false
            self.etaLbl.stringValue = "Arriving shortly"
        } else if tripObj.status == .inProgress {
            self.etaLbl.isHidden = false
            self.etaLbl.stringValue = "\(tripObj.destination?.eta ?? 5) mins"
        }
        self.etaLbl.setKern(1.4)
    }

    fileprivate func updateDriver(_ tripObj: TripObj) {
        guard let driver = tripObj.driver else { return }

        // Name
        self.driverNameLbl.stringValue = driver.name ?? "Unknow"
        self.driverRatingLbl.stringValue = "\(driver.rating ?? 4) ★"

        // Avatar
        if let avatar = driver.pictureUrl {
            DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
                .async {
                    if let url = URL(string: avatar) {
                        let image = NSImage(contentsOf: url)

                        // Update
                        DispatchQueue.main.async {
                            self.driverAvatarImageView.image = image
                        }
                    }
            }
        }
    }

    fileprivate func updateVehicle(_ tripObj: TripObj) {
        guard let vehicle = tripObj.vehicle else { return }
        self.driverModelLbl.stringValue = vehicle.fullName
        self.driverLicensePlateLbl.stringValue = vehicle.licensePlate ?? "Unknow"
    }

    fileprivate func updatePayment() {
        guard let currentUser = UserObj.currentUser else { return }
        guard let account = currentUser.currentPaymentAccountObjVar.value else { return }
        self.paymentImageView.image = NSImage(imageLiteralResourceName: account.type.imageIconName)
        self.cardNumberLbl.stringValue = account.betterAccountDescription
        self.cardNumberLbl.setKern(1.2)
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
