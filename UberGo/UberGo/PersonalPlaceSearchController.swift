//
//  PersonalPlaceSearchController.swift
//  UberGo
//
//  Created by Nghia Tran on 8/14/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import UberGoCore

class PersonalPlaceSearchController: NSViewController {

    // MARK: - Variable
    fileprivate var viewModel: PersonalPlaceSearchViewModel!

    // MARK: - View
    fileprivate lazy var collectionView: SearchCollectionView = self.lazyInitSearchCollectionView()
    fileprivate lazy var searchBarView: SearchBarView = self.lazyInitSearchBarView()

    // MARK: - Init
    init?(viewModel: PersonalPlaceSearchViewModel) {
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

        // Layout
        searchBarView.layoutState = .searchFullScreen
    }

    public func resetTextSearch() {
        searchBarView.resetTextSearch()
    }
}

// MARK: - Private
extension PersonalPlaceSearchController {

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
extension PersonalPlaceSearchController {

    public func configureContainerController(_ controller: NSViewController, containerView: NSView) {
        controller.addChildViewController(self)
        containerView.addSubview(view)
        containerView.edges(to: view)
    }

    public func updateState(_ state: MainLayoutState) {
        searchBarView.layoutState = state
        collectionView.layoutStateChanged(state)
    }
}

// MARK: - SearchBarViewDelegate
extension PersonalPlaceSearchController: SearchBarViewDelegate {

    func searchBar(_ sender: SearchBarView, layoutStateDidChanged state: MainLayoutState) {
//        delegate?.shouldUpdateLayoutState(state)
    }
}

// MARK: - SearchCollectionViewDelegate
extension PersonalPlaceSearchController: SearchCollectionViewDelegate {

    func searchCollectionViewSearchPersonalPlace(_ placeObj: PlaceObj) {
//        viewModel.input.enableFullSearchModePublisher.onNext(true)
//        delegate?.shouldUpdateLayoutState(.searchFullScreen)
    }

    func searchCollectionViewDidSelectPlace(_ placeObj: PlaceObj) {
//        delegate?.didSelectPlace(placeObj)
//        delegate?.shouldUpdateLayoutState(.minimal)
    }
}
