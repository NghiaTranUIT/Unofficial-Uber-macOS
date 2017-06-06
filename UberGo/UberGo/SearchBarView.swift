//
//  SearchBarView.swift
//  UberGo
//
//  Created by Nghia Tran on 6/5/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa
import UberGoCore

class SearchBarView: NSView {

    // MARK: - OUTLET
    @IBOutlet weak var originTxt: NSTextField!
    @IBOutlet weak var destinationTxt: NSTextField!
    @IBOutlet weak var roundBarView: NSView!
    @IBOutlet weak var squareBarView: NSView!
    @IBOutlet weak var lineVerticalView: NSView!
    @IBOutlet weak var backBtn: NSButton!

    // MARK: - Variable
    fileprivate var viewModel: SearchBarViewModel?
    fileprivate var actionSearchView: ActionSearchBarView!

    // Constraint
    fileprivate var topConstraint: NSLayoutConstraint!
    fileprivate var leftConstraint: NSLayoutConstraint!
    fileprivate var rightConstraint: NSLayoutConstraint!

    // MARK: - Init
    override func awakeFromNib() {
        super.awakeFromNib()

        self.initCommon()
        self.initActionSearchView()
        self.binding()
    }

    fileprivate func binding() {
        if self.viewModel == nil {
            let viewModel = SearchBarViewModel()

            self.viewModel = viewModel
        }
    }

    // MARK: - Action
    @IBAction func backBtnOnTap(_ sender: Any) {

    }

}

extension SearchBarView {

    fileprivate func initCommon() {
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.white.cgColor
    }

    fileprivate func initActionSearchView() {
        let actionView = ActionSearchBarView.viewFromNib(with: BundleType.app)!
        actionView.configureView(with: self)
        actionView.delegate = self
        self.actionSearchView = actionView
    }

    func configureView(with parentView: NSView) {
        self.translatesAutoresizingMaskIntoConstraints = false

        parentView.addSubview(self)
        self.topConstraint = NSLayoutConstraint(item: self,
                                     attribute: .top,
                                     relatedBy: .equal,
                                     toItem: parentView,
                                     attribute: .top,
                                     multiplier: 1,
                                     constant: 28)
        self.leftConstraint = NSLayoutConstraint(item: self,
                                      attribute: .left,
                                      relatedBy: .equal,
                                      toItem: parentView,
                                      attribute: .left,
                                      multiplier: 1,
                                      constant: 28)
        self.rightConstraint = NSLayoutConstraint(item: self,
                                       attribute: .right,
                                       relatedBy: .equal,
                                       toItem: parentView,
                                       attribute: .right,
                                       multiplier: 1,
                                       constant: -28)
        let height = NSLayoutConstraint(item: self,
                                       attribute: .height,
                                       relatedBy: .equal,
                                       toItem: nil, attribute: .notAnAttribute,
                                       multiplier: 1,
                                       constant: 56)
        parentView.addConstraints([self.topConstraint, self.leftConstraint, self.rightConstraint, height])
    }

}

// MARK: - ActionSearchBarViewDelegate
extension SearchBarView: ActionSearchBarViewDelegate {

    func shouldOpenScheduler() {
    }

    func shouldOpenFullSearch() {

        // Animate
        self.leftConstraint.constant = 0
        self.topConstraint.constant = 0
        self.rightConstraint.constant = 0

        NSAnimationContext.runAnimationGroup({ context in
            context.allowsImplicitAnimation = true
            context.duration = 0.22
            context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)

            self.actionSearchView.alphaValue = 0
            self.superview?.layoutSubtreeIfNeeded()
        }, completionHandler: nil)
    }
}

// MARK: - XIBInitializable
extension SearchBarView: XIBInitializable {
    typealias XibType = SearchBarView
}
