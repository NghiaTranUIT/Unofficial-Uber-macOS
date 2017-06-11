//
//  SearchPlaceCell.swift
//  UberGo
//
//  Created by Nghia Tran on 6/11/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa
import UberGoCore

class SearchPlaceCell: NSCollectionViewItem {

    // MARK: - OUTLET
    @IBOutlet fileprivate weak var titleLbl: NSTextField!
    @IBOutlet fileprivate weak var addressLbl: NSTextField!
    @IBOutlet fileprivate weak var avatarImageView: NSImageView!
    @IBOutlet fileprivate weak var separateLine: NSView!

    // MARK: - Variable
    fileprivate var trackingArea: NSTrackingArea?
    fileprivate var mouseInside = false {
        didSet {
            updateMouseOverUI()
        }
    }

    // MARK: - View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initCommon()
        self.createTrackingAreaIfNeeded()
    }

    // MARK: - Public
    func configurePlaceCell(_ placeObj: PlaceObj) {
        self.titleLbl.stringValue = placeObj.name ?? ""
        self.addressLbl.stringValue = placeObj.address ?? ""
        self.avatarImageView.image = NSImage(named: placeObj.placeType.iconName)
    }

    override func mouseEntered(with theEvent: NSEvent) {
        mouseInside = true
    }

    override func mouseExited(with theEvent: NSEvent) {
        mouseInside = false
    }
}

// MARK: - Private
extension SearchPlaceCell {

    fileprivate func initCommon() {
        self.view.backgroundColor = NSColor.white
        self.titleLbl.textColor = NSColor.black
        self.addressLbl.textColor = NSColor(hexString: "#A4A4A8")
        self.separateLine.backgroundColor = NSColor(hexString: "#EDEDED")
    }

    fileprivate func createTrackingAreaIfNeeded() {
        if trackingArea == nil {
                trackingArea = NSTrackingArea(rect: CGRect.zero,
                                              options: [NSTrackingAreaOptions.inVisibleRect,
                                                       NSTrackingAreaOptions.mouseEnteredAndExited,
                                                       NSTrackingAreaOptions.activeAlways],
                                              owner: self,
                                              userInfo: nil)
        }
        if self.view.trackingAreas.contains(trackingArea!) == false {
            self.view.addTrackingArea(trackingArea!)
        }
    }

    fileprivate func updateMouseOverUI() {
        NSAnimationContext.runAnimationGroup({ (context) in
            context.allowsImplicitAnimation = true
            context.duration = 0.11
            context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)

            if self.mouseInside {
                self.view.backgroundColor = NSColor(hexString: "#EDEDED")
            } else {
                self.view.backgroundColor = NSColor.white
            }
        }, completionHandler: nil)
    }
}
