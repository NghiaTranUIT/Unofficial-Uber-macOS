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

    override var state: NSControl.StateValue {
        didSet {
            switch state {
            case .on:
                self.font = NSFont.boldSystemFont(ofSize: 15)
                self.setTitleColor(NSColor.black, kern: 2)
            default:
                self.font = NSFont.systemFont(ofSize: 13)
                self.setTitleColor(NSColor.darkGray, kern: 2)
            }
        }
    }

    // MARK: - Init
    convenience init(groupProductObj: GroupProductObj) {
        self.init(frame: NSRect.zero)

        self.groupObj = groupProductObj
        self.title = groupProductObj.productGroup.uppercased()
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
        self.state = .off

        // Targe
        self.target = self
        self.action = #selector(self.groupProductBtnOnTap(_:))
    }
}
