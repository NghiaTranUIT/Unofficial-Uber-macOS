//
//  SearchBarView.swift
//  UberGo
//
//  Created by Nghia Tran on 6/5/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa
import UberGoCore

enum SearchBarViewLayoutState {
    case expanded
    case shrink
}

class SearchBarView: NSView {

    // MARK: - OUTLET
    @IBOutlet fileprivate weak var originTxt: NSTextField!
    @IBOutlet fileprivate weak var destinationTxt: NSTextField!
    @IBOutlet fileprivate weak var roundBarView: NSView!
    @IBOutlet fileprivate weak var squareBarView: NSView!
    @IBOutlet fileprivate weak var lineVerticalView: NSView!
    @IBOutlet fileprivate weak var backBtn: NSButton!
    @IBOutlet fileprivate weak var searchContainerView: NSView!

    // MARK: - Variable
    fileprivate var _layoutState = SearchBarViewLayoutState.shrink { didSet { self.animateSearchBarState() } }
    public fileprivate(set) var layoutState: SearchBarViewLayoutState {
        get {
            return self._layoutState
        }
        set {
            if newValue == _layoutState {
                return
            }
            _layoutState = newValue
        }
    }
    fileprivate var viewModel: SearchBarViewModel?
    fileprivate var actionSearchView: ActionSearchBarView!

    // Constraint
    fileprivate var topConstraint: NSLayoutConstraint!
    fileprivate var leftConstraint: NSLayoutConstraint!
    fileprivate var rightConstraint: NSLayoutConstraint!
    fileprivate var heightConstraint: NSLayoutConstraint!

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
        self.layoutState = .shrink
    }

}

extension SearchBarView {

    fileprivate func initCommon() {
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.white.cgColor

        // Defaukt
        self.searchContainerView.alphaValue = 0
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
        self.heightConstraint = NSLayoutConstraint(item: self,
                                       attribute: .height,
                                       relatedBy: .equal,
                                       toItem: nil, attribute: .notAnAttribute,
                                       multiplier: 1,
                                       constant: 56)
        parentView.addConstraints([self.topConstraint, self.leftConstraint,
                                   self.rightConstraint, self.heightConstraint])
    }

    fileprivate func animateSearchBarState() {
        switch self._layoutState {
        case .expanded:
            self.leftConstraint.constant = 0
            self.topConstraint.constant = 0
            self.rightConstraint.constant = 0
            self.heightConstraint.constant = 142
            
            NSAnimationContext.runAnimationGroup({ context in
                context.allowsImplicitAnimation = true
                context.duration = 0.22
                context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)

                self.actionSearchView.alphaValue = 0
                self.searchContainerView.alphaValue = 1

                self.superview?.layoutSubtreeIfNeeded()
            }, completionHandler: nil)
        case .shrink:
            self.leftConstraint.constant = 28
            self.topConstraint.constant = 28
            self.rightConstraint.constant = -28
            self.heightConstraint.constant = 56

            NSAnimationContext.runAnimationGroup({ context in
                context.allowsImplicitAnimation = true
                context.duration = 0.22
                context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)

                self.actionSearchView.alphaValue = 1
                self.searchContainerView.alphaValue = 0

                self.superview?.layoutSubtreeIfNeeded()
            }, completionHandler: nil)
        }
    }
}

// MARK: - ActionSearchBarViewDelegate
extension SearchBarView: ActionSearchBarViewDelegate {

    func shouldOpenScheduler() {
    }

    func shouldOpenFullSearch() {
        self.layoutState = .expanded
    }
}

// MARK: - XIBInitializable
extension SearchBarView: XIBInitializable {
    typealias XibType = SearchBarView
}
