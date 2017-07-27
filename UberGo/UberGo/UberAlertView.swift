//
//  UberAlertView.swift
//  UberGo
//
//  Created by Nghia Tran on 7/27/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa

class UberAlertView: NSView {

    // MARK: - OUTLET
    @IBOutlet fileprivate var errorTitle: NSTextField!

    // MARK: - Variable
    fileprivate var isShow = false

    // MARK: - Public
    public func showError(_ error: NSError, view: NSView) {
        let title = error.userInfo["message"] as? String ?? error.description

        errorTitle.stringValue = title

        // Animate
        addSubViewIfNeed(view)
        fadeInAnimation()
    }
}

// MARK: - Animation
extension UberAlertView {

    fileprivate func addSubViewIfNeed(_ view: NSView) {
        guard self.superview == nil else { return }

        translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)

        // Constraints
        top(to: view)
        left(to: view)
        right(to: view)
        height(36)
    }

    fileprivate func fadeInAnimation() {

        self.alphaValue = 0

        NSAnimationContext.defaultAnimate({ _ in
            self.alphaValue = 1
        }) {
            self.fadeOutAnimation()
        }
    }

    fileprivate func fadeOutAnimation() {
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 5.0) {
            NSAnimationContext.defaultAnimate({ _ in
                self.alphaValue = 0
            }) {
                self.removeFromSuperview()
            }
        }
    }
}

// MARK: - XIBInitializable
extension UberAlertView: XIBInitializable {
    typealias XibType = UberAlertView
}
