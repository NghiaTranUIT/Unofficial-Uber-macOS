//
//  TripActivityView.swift
//  UberGo
//
//  Created by Nghia Tran on 6/25/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import UberGoCore

protocol TripActivityViewDelegate: class {
    func tripActivityViewShouldCancelCurrentTrip(_ sender: TripActivityView)
}

class TripActivityView: NSView {

    // MARK: - OUTLET

    // Status
    @IBOutlet fileprivate weak var statusContainerView: NSView!
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

    @IBOutlet fileprivate weak var paymentContainerView: NSView!
    @IBOutlet fileprivate weak var paymentImageView: NSImageView!
    @IBOutlet fileprivate weak var cardNumberLbl: UberTextField!

    // MARK: - Variable
    public weak var delegate: TripActivityViewDelegate?

    // MARK: - Init
    override func awakeFromNib() {
        super.awakeFromNib()

        initCommon()
    }

    // MARK: - Public
    public func configureLayout(_ parentView: NSView) {
        translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(self)

        edges(to: parentView)
    }

    public func updateData(_ tripObj: TripObj) {

        // Status
        updateStatus(tripObj)

        // ETA
        updateETA(tripObj)

        // Driver name 
        updateDriver(tripObj)

        // Vehicle
        updateVehicle(tripObj)

        // Destination ETA
        //arrvialTimeLbl.stringValue = tripObj.destination?.eta

        // Current Payment
        updatePayment()
    }

    // MARK: - OUTLET
    @IBAction func cancelTripBtnOnTap(_ sender: Any) {
        guard let window = window else { return }
        NSAlert.confirmationAlertView(showOn: window, title: "Are you sure",
                                      message: "Maybe cause pay deposit money",
                                      okBlock: { [weak self] in

            guard let `self` = self else { return }
            self.delegate?.tripActivityViewShouldCancelCurrentTrip(self)
        }, cancelBlock: nil)
    }

    @IBAction func contactDriverBtnOnTap(_ sender: Any) {

    }
}

// MARK: - Private
extension TripActivityView {

    fileprivate func initCommon() {

        contactDriverBtn.wantsLayer = true
        contactDriverBtn.layer?.borderWidth = 1
        contactDriverBtn.layer?.borderColor = NSColor(hexString: "#ededed").cgColor
        contactDriverBtn.setTitleColor(NSColor(hexString: "#235a92"))

        cancelTripBtn.wantsLayer = true
        cancelTripBtn.layer?.borderWidth = 1
        cancelTripBtn.layer?.borderColor = NSColor(hexString: "#ededed").cgColor
        cancelTripBtn.setTitleColor(NSColor(hexString: "#9e191e"))

        driverLicensePlateLbl.layer?.borderColor = NSColor(hexString: "#a4a5aa").cgColor
        driverLicensePlateLbl.layer?.borderWidth = 1

        dividerFirstView.backgroundColor = NSColor(hexString: "#ededed")
        dividerSecondView.backgroundColor = NSColor(hexString: "#ededed")

        // Kern
        statusLbl.setKern(2.0)
        etaLbl.setKern(1.4)

        // Border
        driverAvatarImageView.wantsLayer = true
        driverAvatarImageView.layer?.cornerRadius = 25
        driverAvatarImageView.layer?.borderColor = NSColor(hexString: "#ededed").cgColor
        driverAvatarImageView.layer?.borderWidth = 1
        driverAvatarImageView.layer?.contentsGravity = kCAGravityResizeAspect
    }
}

// MARK: - Layout
extension TripActivityView {

    fileprivate func updateStatus(_ tripObj: TripObj) {

        // Name
        statusLbl.stringValue = tripObj.status.prettyValue
        statusLbl.setKern(2.0)

        // Enable - Disable
        if tripObj.status == .processing ||
            tripObj.status == .driverCanceled ||
            tripObj.status == .riderCanceled ||
            tripObj.status == .noDriversAvailable ||
            tripObj.status == .unknown {

            contactDriverBtn.isEnabled = false
            shareStatusBtn.isEnabled = false
            changeDestinationBtn.isEnabled = false
        } else {
            contactDriverBtn.isEnabled = true
            shareStatusBtn.isEnabled = true
            changeDestinationBtn.isEnabled = true
        }
    }

    fileprivate func updateETA(_ tripObj: TripObj) {
        etaLbl.isHidden = true
        if tripObj.status == .accepted {
            etaLbl.isHidden = false
            etaLbl.stringValue = "\(tripObj.pickup?.eta ?? 5) mins"
        } else if tripObj.status == .arriving {
            etaLbl.isHidden = false
            etaLbl.stringValue = "Arriving shortly"
        } else if tripObj.status == .inProgress {
            etaLbl.isHidden = false
            etaLbl.stringValue = "\(tripObj.destination?.eta ?? 5) mins"
        }
        etaLbl.setKern(1.4)
    }

    fileprivate func updateDriver(_ tripObj: TripObj) {
        guard let driver = tripObj.driver else { return }

        // Name
        driverNameLbl.stringValue = driver.name
        driverRatingLbl.stringValue = "\(driver.rating)"

        // Avatar
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
            .async { [weak self] in
                guard let url = URL(string: driver.pictureUrl) else { return }
                let image = NSImage(contentsOf: url)
                DispatchQueue.main.async { [weak self] in
                    self?.driverAvatarImageView.image = image
                }
            }
    }

    fileprivate func updateVehicle(_ tripObj: TripObj) {
        guard let vehicle = tripObj.vehicle else { return }
        driverModelLbl.stringValue = vehicle.fullName
        driverLicensePlateLbl.stringValue = vehicle.licensePlate
    }

    fileprivate func updatePayment() {
        guard let currentUser = UberAuth.share.currentUser else { return }
        guard let account = currentUser.currentPaymentAccountObjVar.value else { return }
        paymentImageView.image = NSImage(imageLiteralResourceName: account.type.imageIconName)
        cardNumberLbl.stringValue = account.betterAccountDescription
        cardNumberLbl.setKern(1.2)
    }
}

// MARK: - XIBInitializable
extension TripActivityView: XIBInitializable {
    typealias XibType = TripActivityView
}
