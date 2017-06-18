//
//  RequestUberView.swift
//  UberGo
//
//  Created by Nghia Tran on 6/17/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa
import UberGoCore

class RequestUberView: NSView {

    // MARK: - OUTLET
    @IBOutlet fileprivate weak var requestUberBtn: UberButton!
    @IBOutlet fileprivate weak var scheduleUberBtn: NSButton!
    @IBOutlet fileprivate weak var paymentImageView: NSButton!
    @IBOutlet fileprivate weak var cardNumberLbl: UberTextField!
    @IBOutlet fileprivate weak var seatNumberLnl: NSTextField!
    @IBOutlet fileprivate weak var dividerLineView: NSView!
    @IBOutlet fileprivate weak var scrollView: NSScrollView!
    @IBOutlet fileprivate weak var collectionView: NSCollectionView!
    @IBOutlet fileprivate weak var stackView: NSStackView!

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

    func updateAvailableGroupProducts(_ groupProductObjs: [GroupProductObj]) {

        // Update Stack
        self.updateStackView(groupProductObjs)
    }

    // MARK: - Stack View
    fileprivate func updateStackView(_ groupProductObjs: [GroupProductObj]) {
        
    }
}

// MARK: - Private
extension RequestUberView {

    fileprivate func initCommon() {
        self.backgroundColor = NSColor(hexString: "#343332")
        self.requestUberBtn.backgroundColor = NSColor.white
        self.requestUberBtn.setTitleColor(NSColor.black, kern: 2)
        self.cardNumberLbl.textColor = NSColor.white
        self.scrollView.backgroundColor = NSColor(hexString: "#343332")
        self.collectionView.backgroundColor = NSColor(hexString: "#343332")
        self.seatNumberLnl.textColor = NSColor.white
        self.dividerLineView.backgroundColor = NSColor.white

        // Border
        self.scheduleUberBtn.wantsLayer = true
        self.scheduleUberBtn.layer?.borderColor = NSColor.white.cgColor
        self.scheduleUberBtn.layer?.borderWidth = 1
        self.scheduleUberBtn.layer?.cornerRadius = 4
        self.scheduleUberBtn.layer?.masksToBounds = true

        // Kern
        self.cardNumberLbl.setKern(1.2)
    }
}

// MARK: - XIBInitializable
extension RequestUberView: XIBInitializable {
    typealias XibType = RequestUberView
}
