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
    func searchBar(_ sender: SearchBarView, layoutStateDidChanged state: MainLayoutState)
}

class SearchBarView: NSView {

    // MARK: - OUTLET
    @IBOutlet fileprivate weak var originTxt: UberTextField!
    @IBOutlet fileprivate weak var destinationTxt: UberTextField!
    @IBOutlet fileprivate weak var roundBarView: NSView!
    @IBOutlet fileprivate weak var squareBarView: NSView!
    @IBOutlet fileprivate weak var lineVerticalView: NSView!
    @IBOutlet fileprivate weak var backBtn: NSButton!
    @IBOutlet fileprivate weak var backBtnTop: NSLayoutConstraint!
    @IBOutlet fileprivate weak var searchContainerView: NSView!
    @IBOutlet fileprivate weak var loaderView: NSProgressIndicator!

    // Container
    @IBOutlet fileprivate weak var originContainerView: NSView!
    @IBOutlet fileprivate weak var destinationContainerView: NSView!

    // MARK: - Variable
    weak var delegate: SearchBarViewDelegate?
    var layoutState = MainLayoutState.minimal {
        didSet {
            animateSearchBarState()
        }
    }
    public var textSearchDidChangedDriver: Driver<String> {
        return destinationTxt.rx.text
            .asObservable()
            .filterNil()
            .asDriver(onErrorJustReturn: "")
    }
    public var textSearch: String {
        return destinationTxt.stringValue
    }

    fileprivate var viewModel: SearchViewModelProtocol!
    fileprivate var actionSearchView: ActionSearchBarView!
    fileprivate let disposeBag = DisposeBag()

    // Constraint
    fileprivate var topConstraint: NSLayoutConstraint!
    fileprivate var leftConstraint: NSLayoutConstraint!
    fileprivate var rightConstraint: NSLayoutConstraint!
    fileprivate var heightConstraint: NSLayoutConstraint!

    // MARK: - Init
    override func awakeFromNib() {
        super.awakeFromNib()

        initCommon()
        initActionSearchView()
    }

    fileprivate func binding() {

        // Nearest place
        viewModel.output.currentPlaceDriver
            .drive(onNext: { [weak self] nearestPlaceObj in
                guard let `self` = self else { return }
                self.updateOriginPlace(nearestPlaceObj)
            })
            .addDisposableTo(disposeBag)

        // Input search
        textSearchDidChangedDriver
            .drive(onNext: {[weak self] text in
                guard let `self` = self else { return }
                self.viewModel.input.textSearchPublish.onNext(text)
            })
            .addDisposableTo(disposeBag)

        // Loader
        viewModel.output.loadingDriver
            .drive(onNext: {[weak self] (isLoading) in
                guard let `self` = self else { return }
                self.loaderIndicatorView(isLoading)
            }).addDisposableTo(disposeBag)
    }

    public func setupViewModel(_ viewModel: SearchViewModelProtocol) {
        self.viewModel = viewModel
        binding()
    }

    fileprivate func updateOriginPlace(_ place: PlaceObj) {
        originTxt.stringValue = place.name
    }

    func makeDestinationFirstResponse() {
        destinationTxt.window?.makeFirstResponder(destinationTxt)
    }

    func resetTextSearch() {
        destinationTxt.stringValue = ""
        loaderIndicatorView(false)
    }

    func loaderIndicatorView(_ isLoading: Bool) {
        if isLoading {
            loaderView.isHidden = false
            loaderView.startAnimation(nil)
        } else {
            loaderView.isHidden = true
            loaderView.stopAnimation(nil)
        }
    }

    // MARK: - Action
    @IBAction func backBtnOnTap(_ sender: Any) {
        viewModel.input.enableFullSearchModePublisher.onNext(false)
        delegate?.searchBar(self, layoutStateDidChanged: .minimal)
    }
}

extension SearchBarView {

    fileprivate func initCommon() {

        // Background
        backgroundColor = NSColor.white
        squareBarView.backgroundColor = NSColor.black
        lineVerticalView.backgroundColor = NSColor(hexString: "#A4A4AC")
        roundBarView.backgroundColor = NSColor(hexString: "#A4A4AC")
        roundBarView.wantsLayer = true
        roundBarView.layer?.masksToBounds = true
        roundBarView.layer?.cornerRadius = 3

        // Default
        searchContainerView.alphaValue = 0
    }

    fileprivate func initActionSearchView() {
        let actionView = ActionSearchBarView.viewFromNib(with: BundleType.app)!
        actionView.configureView(with: self)
        actionView.delegate = self
        actionSearchView = actionView
    }
}

// MARK: - Layout
extension SearchBarView {

    func configureView(with parentView: NSView) {
        translatesAutoresizingMaskIntoConstraints = false
        topConstraint = top(to: parentView, offset: 28)
        leftConstraint = left(to: parentView, offset: 28)
        rightConstraint = right(to: parentView, offset: -28)
        heightConstraint = height(56)
    }

    fileprivate func animateSearchBarState() {
        switch layoutState {
        case .expand:
            expandAnimation()
        case .minimal:
            minimalAnimation()
        case .searchFullScreen:
            searchFullScreenAnimation()
        case .tripMinimunActivity,
             .tripFullActivity,
             .productSelection:
            hideAllAnimation()
        }
    }

    fileprivate func expandAnimation() {
        // Focus
        makeDestinationFirstResponse()

        isHidden = false
        leftConstraint.constant = 0
        topConstraint.constant = 0
        rightConstraint.constant = 0
        heightConstraint.constant = 142
        backBtnTop.constant = 15

        // Animate
        NSAnimationContext.defaultAnimate({ _ in
            self.alphaValue = 1
            self.originContainerView.alphaValue = 1
            self.roundBarView.alphaValue = 1
            self.squareBarView.alphaValue = 1
            self.lineVerticalView.alphaValue = 1

            self.actionSearchView.alphaValue = 0
            self.searchContainerView.alphaValue = 1
            self.superview?.layoutSubtreeIfNeeded()
        })
    }

    fileprivate func minimalAnimation() {
        isHidden = false
        leftConstraint.constant = 28
        topConstraint.constant = 28
        rightConstraint.constant = -28
        heightConstraint.constant = 56
        backBtnTop.constant = 15

        NSAnimationContext.defaultAnimate({ _ in
            self.alphaValue = 1
            self.actionSearchView.alphaValue = 1
            self.searchContainerView.alphaValue = 0
            self.superview?.layoutSubtreeIfNeeded()
        })
    }

    fileprivate func searchFullScreenAnimation() {

        // Focus
        makeDestinationFirstResponse()

        isHidden = false
        leftConstraint.constant = 0
        topConstraint.constant = 0
        rightConstraint.constant = 0
        heightConstraint.constant = 48
        backBtnTop.constant = 8

        // Animate
        NSAnimationContext.defaultAnimate({ _ in
            self.alphaValue = 1
            self.originContainerView.alphaValue = 0
            self.roundBarView.alphaValue = 0
            self.squareBarView.alphaValue = 0
            self.lineVerticalView.alphaValue = 0

            self.actionSearchView.alphaValue = 0
            self.searchContainerView.alphaValue = 1
            self.superview?.layoutSubtreeIfNeeded()
        })
    }

    fileprivate func hideAllAnimation() {
        NSAnimationContext.defaultAnimate({ _ in
            self.alphaValue = 0
            self.superview?.layoutSubtreeIfNeeded()
        }, completion: {
            self.isHidden = true
        })
    }
}

// MARK: - ActionSearchBarViewDelegate
extension SearchBarView: ActionSearchBarViewDelegate {

    func shouldOpenFullSearch() {
        delegate?.searchBar(self, layoutStateDidChanged: .expand)
    }
}

// MARK: - XIBInitializable
extension SearchBarView: XIBInitializable {
    typealias XibType = SearchBarView
}
