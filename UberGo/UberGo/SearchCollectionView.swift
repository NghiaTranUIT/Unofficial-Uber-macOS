//
//  SearchCollectionView.swift
//  UberGo
//
//  Created by Nghia Tran on 6/11/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa
import RxSwift
import UberGoCore

protocol SearchCollectionViewDelegate: class {
    func searchCollectionViewSearchPersonalPlace(_ placeObj: PlaceObj)
    func searchCollectionViewDidSelectPlace(_ placeObj: PlaceObj)
}

class SearchCollectionView: NSView {

    // MARK: - OUTLET
    @IBOutlet fileprivate weak var collectionView: UberCollectionView!

    // MARK: - Variable
    fileprivate var viewModel: SearchViewModelProtocol!
    fileprivate let disposeBag = DisposeBag()
    fileprivate var placeObjs: [PlaceObj] { return viewModel.output.searchPlacesVar.value }

    weak var delegate: SearchCollectionViewDelegate?

    // MARK: - View Cycle
    override func awakeFromNib() {
        super.awakeFromNib()

        initCommon()
        setupCollectionView()
    }

    // MARK: - Public
    public func setupViewModel(_ viewModel: SearchViewModelProtocol) {
        self.viewModel = viewModel
        binding()
    }

    fileprivate func binding() {

        // Reload search Place collectionView
        viewModel.output.searchPlacesVar
            .asObservable()
            .subscribe(onNext: {[weak self] placeObjs in
                guard let `self` = self else { return }
                Logger.info("Place Search FOUND = \(placeObjs.count)")
                self.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Private
extension SearchCollectionView {

    fileprivate func initCommon() {
        translatesAutoresizingMaskIntoConstraints = false
        alphaValue = 0
        isHidden = true
    }

    fileprivate func setupCollectionView() {

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = false
        collectionView.allowsEmptySelection = false

        // Register
        let nib = NSNib(nibNamed: NSNib.Name(rawValue: "SearchPlaceCell"), bundle: nil)
        collectionView.register(nib, forItemWithIdentifier: NSUserInterfaceItemIdentifier("SearchPlaceCell"))

        // Flow
        let flow = SearchCollectionViewFlowLayout()
        flow.itemSize = CGSize(width: collectionView.bounds.width, height: 57)
        collectionView.collectionViewLayout = flow
    }
}

// MARK: - Layout
extension SearchCollectionView {

    public func configureView(parenView: NSView, searchBarView: SearchBarView) {
        translatesAutoresizingMaskIntoConstraints = false
        topToBottom(of: searchBarView)
        left(to: parenView)
        right(to: parenView)
        bottom(to: parenView)
    }

    public func layoutStateChanged(_ newState: MainLayoutState) {
        switch newState {
        case .searchFullScreen, .expand:
            isHidden = false
            alphaValue = 0

            // Animate
            NSAnimationContext.defaultAnimate({ _ in
                self.alphaValue = 1
            })
        case .minimal, .tripMinimunActivity, .tripFullActivity, .productSelection:
            isHidden = false
            alphaValue = 1

            // Animate
            NSAnimationContext.defaultAnimate({ _ in
                self.alphaValue = 0
            }, completion: {
                self.isHidden = true
            })
        }
    }
}

// MARK: - XIBInitializable
extension SearchCollectionView: XIBInitializable {
    typealias XibType = SearchCollectionView
}

// MARK: - NSCollectionViewDataSource
extension SearchCollectionView: NSCollectionViewDataSource {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return placeObjs.count
    }

    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath)
        -> NSCollectionViewItem {
            return getSearchCell(with: collectionView, indexPath: indexPath)
    }

    fileprivate func getSearchCell(with collectionView: NSCollectionView, indexPath: IndexPath)
        -> NSCollectionViewItem {

            // Guard
            guard let cell = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "SearchPlaceCell"), for: indexPath)
                as? SearchPlaceCell else {
                    return NSCollectionViewItem()
            }

            let placeObj = placeObjs[indexPath.item]
            cell.configurePlaceCell(placeObj)
            return cell
    }
}

// MARK: - NSCollectionViewDelegate
extension SearchCollectionView: NSCollectionViewDelegate, NSCollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        let selection = indexPaths as NSSet

        guard let selectedIndexPath = selection.allObjects.last as? IndexPath else { return }

        // Data
        let placeObj = placeObjs[selectedIndexPath.item]

        // De-select
        collectionView.deselectItems(at: indexPaths)

        // If invalid personal place
        // Add New place
        if placeObj.invalid {

            // Temporary disable this feature
            return
//            delegate?.searchCollectionViewSearchPersonalPlace(placeObj)
//            return
        }

        // Select and reset data
        viewModel.input.selectPlaceObjPublisher.onNext(placeObj)
        viewModel.input.textSearchPublish.onNext("")

        // Notify delegate
        delegate?.searchCollectionViewDidSelectPlace(placeObj)
    }
}
