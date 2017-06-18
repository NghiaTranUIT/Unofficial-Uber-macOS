//
//  UberGroupButton.swift
//  UberGo
//
//  Created by Nghia Tran on 6/18/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa
import UberGoCore

protocol UberGroupButtonDelegate: class {
    func uberGroupButton(_ sender: UberGroupButton, didSelectedGroupObj groupObj: GroupProductObj)
}

class UberGroupButton: UberButton {


    // MARK: - Variable
    public fileprivate(set) weak var groupObj: GroupProductObj?
    weak var delegate: UberGroupButtonDelegate?

    override var state: Int {
        didSet {
            if state == NSOnState {
                self.font = NSFont.systemFont(ofSize: 14)
                self.setTitleColor(NSColor.white, kern: 2)
            } else {
                self.font = NSFont.systemFont(ofSize: 13)
                self.setTitleColor(NSColor.lightGray, kern: 2)
            }
        }
    }

    // MARK: - Init
    convenience init(groupProductObj: GroupProductObj) {
        self.init(frame: NSRect.zero)

        self.groupObj = groupProductObj
        self.title = groupProductObj.productGroup.capitalized
        self.initCommon()
    }

    @objc fileprivate func groupProductBtnOnTap(_ sender: UberButton) {
        guard let group = self.groupObj else {
            return
        }

        self.delegate?.uberGroupButton(self, didSelectedGroupObj: group)
    }
}

// MARK: - Private
extension UberGroupButton {

    fileprivate func initCommon() {
        self.font = NSFont.systemFont(ofSize: 13)
        self.isBordered = false

        // Targe
        self.target = self
        self.action = #selector(self.groupProductBtnOnTap(_:))
    }
}
