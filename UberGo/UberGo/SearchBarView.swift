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
    var layoutState = MapViewLayoutState.minimal {
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

    fileprivate var viewModel: MapViewModel!
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
                self.updateNestestPlace(nearestPlaceObj)
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

    public func setupViewModel(_ viewModel: MapViewModel) {
        self.viewModel = viewModel
        binding()
    }

    fileprivate func updateNestestPlace(_ place: PlaceObj) {
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

            // Focus
            makeDestinationFirstResponse()

            isHidden = false
            leftConstraint.constant = 0
            topConstraint.constant = 0
            rightConstraint.constant = 0
            heightConstraint.constant = 142

            // Animate
            NSAnimationContext.defaultAnimate({ _ in
                self.alphaValue = 1
                self.actionSearchView.alphaValue = 0
                self.searchContainerView.alphaValue = 1
                self.superview?.layoutSubtreeIfNeeded()
            })
        case .minimal:
            isHidden = false
            leftConstraint.constant = 28
            topConstraint.constant = 28
            rightConstraint.constant = -28
            heightConstraint.constant = 56

            NSAnimationContext.defaultAnimate({ _ in
                self.alphaValue = 1
                self.actionSearchView.alphaValue = 1
                self.searchContainerView.alphaValue = 0
                self.superview?.layoutSubtreeIfNeeded()
            })
        case .tripMinimunActivity:
            fallthrough
        case .tripFullActivity:
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
        delegate?.searchBar(self, layoutStateDidChanged: .expand)
    }
}

// MARK: - XIBInitializable
extension SearchBarView: XIBInitializable {
    typealias XibType = SearchBarView
}
