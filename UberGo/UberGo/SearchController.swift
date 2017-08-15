//
//  SearchController.swift
//  UberGo
//
//  Created by Nghia Tran on 8/3/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import UberGoCore

protocol SearchControllerDelegate: class {

    func didSelectPlace(_ placeObj: PlaceObj)
    func shouldUpdateLayoutState(_ newState: MapViewLayoutState)
}

class SearchController: NSViewController {

    // MARK: - Variable
    fileprivate var viewModel: SearchViewModel!
    public weak var delegate: SearchControllerDelegate?

    // MARK: - View
    fileprivate lazy var collectionView: SearchCollectionView = self.lazyInitSearchCollectionView()
    fileprivate lazy var searchBarView: SearchBarView = self.lazyInitSearchBarView()

    // MARK: - Init
    init?(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "SearchController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        initCommon()

        // Setup
        searchBarView.setupViewModel(viewModel)
        collectionView.setupViewModel(viewModel)
    }

    public func resetTextSearch() {
        searchBarView.resetTextSearch()
    }
}

// MARK: - Private
extension SearchController {

    fileprivate func initCommon() {
        view.backgroundColor = NSColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
    }

    fileprivate func lazyInitSearchBarView() -> SearchBarView {
        let searchView = SearchBarView.viewFromNib(with: BundleType.app)!
        searchView.delegate = self
        view.addSubview(searchView)
        searchView.configureView(with: view)
        return searchView
    }

    fileprivate func lazyInitSearchCollectionView() -> SearchCollectionView {
        let collectionView = SearchCollectionView.viewFromNib(with: BundleType.app)!
        collectionView.delegate = self
        self.view.addSubview(collectionView)
        collectionView.configureView(parenView: view, searchBarView: searchBarView)
        return collectionView
    }
}

// MARK: - Layout
extension SearchController {

    public func configureContainerController(_ controller: NSViewController, containerView: NSView) {
        controller.addChildViewController(self)
        containerView.addSubview(view)
        containerView.edges(to: view)
    }

    public func updateState(_ state: MapViewLayoutState) {
        searchBarView.layoutState = state
        collectionView.layoutStateChanged(state)
    }
}

// MARK: - SearchBarViewDelegate
extension SearchController: SearchBarViewDelegate {

    func searchBar(_ sender: SearchBarView, layoutStateDidChanged state: MapViewLayoutState) {
        delegate?.shouldUpdateLayoutState(state)
    }
}

// MARK: - SearchCollectionViewDelegate
extension SearchController: SearchCollectionViewDelegate {

    func searchCollectionViewSearchPersonalPlace(_ placeObj: PlaceObj) {
        viewModel.input.enableFullSearchModePublisher.onNext(true)
        delegate?.shouldUpdateLayoutState(.searchFullScreen)
    }

    func searchCollectionViewDidSelectPlace(_ placeObj: PlaceObj) {
        delegate?.didSelectPlace(placeObj)
        delegate?.shouldUpdateLayoutState(.minimal)
    }
}
