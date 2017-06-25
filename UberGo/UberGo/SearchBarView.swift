//
//  SearchBarView.swift
//  UberGo
//
//  Created by Nghia Tran on 6/5/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa
import RxCocoa
import RxSwift
import UberGoCore

protocol SearchBarViewDelegate: class {
    func searchBar(_ sender: SearchBarView, layoutStateDidChanged state: MapViewLayoutState)
}

class SearchBarView: NSView {

    // MARK: - OUTLET
    @IBOutlet fileprivate weak var originTxt: UberTextField!
    @IBOutlet fileprivate weak var destinationTxt: UberTextField!
    @IBOutlet fileprivate weak var roundBarView: NSView!
    @IBOutlet fileprivate weak var squareBarView: NSView!
    @IBOutlet fileprivate weak var lineVerticalView: NSView!
    @IBOutlet fileprivate weak var backBtn: NSButton!
    @IBOutlet fileprivate weak var searchContainerView: NSView!
    @IBOutlet fileprivate weak var loaderView: NSProgressIndicator!

    // MARK: - Variable
    weak var delegate: SearchBarViewDelegate?
    fileprivate var _layoutState = MapViewLayoutState.minimal {
        didSet {
            self.delegate?.searchBar(self, layoutStateDidChanged: _layoutState)
            self.animateSearchBarState()
        }
    }
    public var layoutState: MapViewLayoutState {
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
    public var textSearchDidChangedDriver: Driver<String> {
        return self.destinationTxt.rx.text
            .asObservable()
            .filterNil()
            .asDriver(onErrorJustReturn: "")
    }
    public var textSearch: String {
        return self.destinationTxt.stringValue
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

    func updateNestestPlace(_ place: PlaceObj) {
        self.originTxt.stringValue = place.name ?? "Unknow position"
    }

    func makeDestinationFirstResponse() {
        self.destinationTxt.window?.makeFirstResponder(self.destinationTxt)
    }

    func loaderIndicatorView(_ isLoading: Bool) {
        if isLoading {
            self.loaderView.isHidden = false
            self.loaderView.startAnimation(nil)
        } else {
            self.loaderView.isHidden = true
            self.loaderView.stopAnimation(nil)
        }
    }
    // MARK: - Action
    @IBAction func backBtnOnTap(_ sender: Any) {
        self.layoutState = .minimal
    }

}

extension SearchBarView {

    fileprivate func initCommon() {

        // Background
        self.backgroundColor = NSColor.white
        self.squareBarView.backgroundColor = NSColor.black
        self.lineVerticalView.backgroundColor = NSColor(hexString: "#A4A4AC")
        self.roundBarView.backgroundColor = NSColor(hexString: "#A4A4AC")
        self.roundBarView.wantsLayer = true
        self.roundBarView.layer?.masksToBounds = true
        self.roundBarView.layer?.cornerRadius = 3

        // Default
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
        case .expand:

            // Focus
            self.makeDestinationFirstResponse()

            self.isHidden = false
            self.leftConstraint.constant = 0
            self.topConstraint.constant = 0
            self.rightConstraint.constant = 0
            self.heightConstraint.constant = 142

            // Animate
            NSAnimationContext.defaultAnimate({ _ in
                self.alphaValue = 1
                self.actionSearchView.alphaValue = 0
                self.searchContainerView.alphaValue = 1
                self.superview?.layoutSubtreeIfNeeded()
            })
        case .minimal:
            self.isHidden = false
            self.leftConstraint.constant = 28
            self.topConstraint.constant = 28
            self.rightConstraint.constant = -28
            self.heightConstraint.constant = 56

            NSAnimationContext.defaultAnimate({ _ in
                self.alphaValue = 1
                self.actionSearchView.alphaValue = 1
                self.searchContainerView.alphaValue = 0
                self.superview?.layoutSubtreeIfNeeded()
            })
        case .tripActivity:
            fallthrough
        case .productSelection:

            NSAnimationContext.defaultAnimate({ _ in
                self.alphaValue = 0
                self.superview?.layoutSubtreeIfNeeded()
            }, completion: {
                self.isHidden = true
            })
        }
    }
}

// MARK: - ActionSearchBarViewDelegate
extension SearchBarView: ActionSearchBarViewDelegate {

    func shouldOpenScheduler() {
    }

    func shouldOpenFullSearch() {
        self.layoutState = .expand
    }
}

// MARK: - XIBInitializable
extension SearchBarView: XIBInitializable {
    typealias XibType = SearchBarView
}
