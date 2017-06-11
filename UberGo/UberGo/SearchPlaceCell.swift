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

    // MARK: - View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initCommon()
    }

    // MARK: - Public
    func configureCell(with placeObj: PlaceObj) {
        self.titleLbl.stringValue = placeObj.name ?? ""
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
}
