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
            self.animateSearchBarState()
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

        self.initCommon()
        self.initActionSearchView()
    }

    fileprivate func binding() {

        // Nearest place
        viewModel.output.nearestPlaceDriver
            .drive(onNext: { [weak self] nearestPlaceObj in
                guard let `self` = self else { return }
                self.updateNestestPlace(nearestPlaceObj)
            })
            .addDisposableTo(disposeBag)

        // Input search
        self.textSearchDidChangedDriver
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
        self.originTxt.stringValue = place.name ?? "Unknow position"
    }

    func makeDestinationFirstResponse() {
        self.destinationTxt.window?.makeFirstResponder(self.destinationTxt)
    }

    func resetTextSearch() {
        self.destinationTxt.stringValue = ""
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
        self.delegate?.searchBar(self, layoutStateDidChanged: .minimal)
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

        self.topConstraint = self.top(to: parentView, offset: 28)
        self.leftConstraint = self.left(to: parentView, offset: 28)
        self.rightConstraint = self.right(to: parentView, offset: -28)
        self.heightConstraint = self.height(56)
    }

    fileprivate func animateSearchBarState() {
        switch self.layoutState {
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
        self.delegate?.searchBar(self, layoutStateDidChanged: .expand)
    }
}

// MARK: - XIBInitializable
extension SearchBarView: XIBInitializable {
    typealias XibType = SearchBarView
}
