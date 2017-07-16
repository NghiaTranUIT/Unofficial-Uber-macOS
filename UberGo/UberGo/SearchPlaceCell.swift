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

        initCommon()
        createTrackingAreaIfNeeded()
    }

    // MARK: - Public
    func configurePlaceCell(_ placeObj: PlaceObj) {
        titleLbl.stringValue = placeObj.name
        addressLbl.stringValue = placeObj.address
        avatarImageView.image = NSImage(imageLiteralResourceName: placeObj.iconName)
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
        view.backgroundColor = NSColor.white
        titleLbl.textColor = NSColor.black
        addressLbl.textColor = NSColor(hexString: "#A4A4A8")
        separateLine.backgroundColor = NSColor(hexString: "#EDEDED")
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
        if view.trackingAreas.contains(trackingArea!) == false {
            view.addTrackingArea(trackingArea!)
        }
    }

    fileprivate func updateMouseOverUI() {

        NSAnimationContext.defaultAnimate({ (context) in
            // rapid
            context.duration = 0.11

            if mouseInside {
                view.backgroundColor = NSColor(hexString: "#EDEDED")
            } else {
                view.backgroundColor = NSColor.white
            }
        })
    }
}
