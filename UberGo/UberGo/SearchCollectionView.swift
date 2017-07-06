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
    func searchCollectionViewDidSelectItem()
}

class SearchCollectionView: NSView {

    // MARK: - OUTLET
    @IBOutlet fileprivate weak var collectionView: UberCollectionView!

    // MARK: - Variable
    fileprivate var viewModel: MapViewModel!
    fileprivate let disposeBag = DisposeBag()
    weak var delegate: SearchCollectionViewDelegate?

    // MARK: - View Cycle
    override func awakeFromNib() {
        super.awakeFromNib()

        self.initCommon()
        self.setupCollectionView()
    }

    // MARK: - Public
    func reloadData() {
        self.collectionView.reloadData()
    }

    public func setupViewModel(_ viewModel: MapViewModel) {
        self.viewModel = viewModel
        binding()
    }

    fileprivate func binding() {

        // Reload search Place collectionView
        viewModel.output.searchPlaceObjsVariable
            .asObservable()
            .subscribe(onNext: {[weak self] placeObjs in
                guard let `self` = self else { return }
                Logger.info("Place Search FOUND = \(placeObjs.count)")
                self.reloadData()
            })
            .addDisposableTo(disposeBag)
    }
}

// MARK: - Private
extension SearchCollectionView {

    fileprivate func initCommon() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.alphaValue = 0
        self.isHidden = true
    }

    fileprivate func setupCollectionView() {

        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.allowsMultipleSelection = false
        self.collectionView.allowsEmptySelection = false

        // Register
        let nib = NSNib(nibNamed: "SearchPlaceCell", bundle: nil)
        self.collectionView.register(nib, forItemWithIdentifier: "SearchPlaceCell")

        // Flow
        let flow = SearchCollectionViewFlowLayout()
        flow.itemSize = CGSize(width: self.collectionView.bounds.width, height: 57)
        self.collectionView.collectionViewLayout = flow
    }
}

// MARK: - Layout
extension SearchCollectionView {

    public func configureView(parenView: NSView, searchBarView: SearchBarView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.topToBottom(of: searchBarView)
        self.left(to: parenView)
        self.right(to: parenView)
        self.bottom(to: parenView)
    }

    public func layoutStateChanged(_ newState: MapViewLayoutState) {
        switch newState {
        case .expand:
            self.isHidden = false
            self.alphaValue = 0

            // Animate
            NSAnimationContext.defaultAnimate({ _ in
                self.alphaValue = 1
            })
        case .minimal:
            fallthrough
        case .tripMinimunActivity:
            fallthrough
        case .tripFullActivity:
            fallthrough
        case .productSelection:
            self.isHidden = false
            self.alphaValue = 1

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
        return viewModel.output.searchPlaceObjsVariable.value.count
    }

    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath)
        -> NSCollectionViewItem {
            return self.getSearchCell(with: collectionView, indexPath: indexPath)
    }

    fileprivate func getSearchCell(with collectionView: NSCollectionView, indexPath: IndexPath)
        -> NSCollectionViewItem {

            // Guard
            guard let cell = collectionView.makeItem(withIdentifier: "SearchPlaceCell", for: indexPath)
                as? SearchPlaceCell else {
                    return NSCollectionViewItem()
            }

            let placeObj = viewModel.output.searchPlaceObjsVariable.value[indexPath.item]
            cell.configurePlaceCell(placeObj)
            return cell
    }
}

// MARK: - NSCollectionViewDelegate
extension SearchCollectionView: NSCollectionViewDelegate, NSCollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        let selection = indexPaths as NSSet
        guard let selectedIndexPath = selection.allObjects.last as? IndexPath else { return }

        // Select
        let placeObj = viewModel.output.searchPlaceObjsVariable.value[selectedIndexPath.item]
        viewModel.input.didSelectPlaceObjPublisher.onNext(placeObj)

        // De-select
        self.collectionView.deselectItems(at: indexPaths)

        // Notify delegate
        delegate?.searchCollectionViewDidSelectItem()
    }
}
