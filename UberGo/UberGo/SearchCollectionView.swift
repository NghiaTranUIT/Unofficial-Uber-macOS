//
//  SearchCollectionView.swift
//  UberGo
//
//  Created by Nghia Tran on 6/8/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa

class SearchCollectionView: NSCollectionView {

    // MARK: - Variable

    convenience init(defaultValue: Bool) {
        self.init()
        self.initCommon()
    }

    // MARK: - Public
    func configureView(parenView: NSView, searchBarView: SearchBarView) {
        parenView.addSubview(self)
        let top = NSLayoutConstraint(item: self,
                                     attribute: .top,
                                     relatedBy: .equal,
                                     toItem: searchBarView,
                                     attribute: .bottom,
                                     multiplier: 1,
                                     constant: 0)
        let left = NSLayoutConstraint(item: self,
                                      attribute: .left,
                                      relatedBy: .equal,
                                      toItem: parenView,
                                      attribute: .left,
                                      multiplier: 1,
                                      constant: 0)
        let right = NSLayoutConstraint(item: self,
                                       attribute: .right,
                                       relatedBy: .equal,
                                       toItem: parenView,
                                       attribute: .right,
                                       multiplier: 1,
                                       constant: 0)
        let bottom = NSLayoutConstraint(item: self,
                                        attribute: .bottom,
                                        relatedBy: .equal,
                                        toItem: parenView,
                                        attribute: .bottom,
                                        multiplier: 1,
                                        constant: 0)
        parenView.addConstraints([left, top, bottom, right])
    }

    func layoutStateChanged(_ newState: SearchBarViewLayoutState) {
        switch newState {
        case .expanded:

            // Force 
            self.isHidden = false
            self.alphaValue = 0

            // Animate
            NSAnimationContext.runAnimationGroup({ context in
                context.allowsImplicitAnimation = true
                context.duration = 0.22
                context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)

                self.alphaValue = 1
            }, completionHandler: nil)
        case .shrink:

            // Force
            self.isHidden = false
            self.alphaValue = 1

            // Animate
            NSAnimationContext.runAnimationGroup({ context in
                context.allowsImplicitAnimation = true
                context.duration = 0.22
                context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)

                self.alphaValue = 0
            }, completionHandler: {
                self.isHidden = true
            })
        }
    }

    // MARK: - Override
    // Flip macOS system coordinate 
    // to correspond with iOS
    override open var isFlipped: Bool {
        return true
    }
}

// MARK: - Private
extension NSCollectionView {

    fileprivate func initCommon() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.alphaValue = 0
        self.isHidden = true
    }
}
