//
//  SearchCollectionView.swift
//  UberGo
//
//  Created by Nghia Tran on 6/11/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa
import UberGoCore

protocol SearchCollectionViewDelegate: class {
    func searchCollectionViewNumberOfPlace() -> Int
    func searchCollectionView(_ sender: SearchCollectionView, atIndex: IndexPath) -> PlaceObj
}

class SearchCollectionView: NSView {

    // MARK: - OUTLET
    @IBOutlet fileprivate weak var collectionView: UberCollectionView!

    // MARK: - Variable
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

    func configureView(parenView: NSView, searchBarView: SearchBarView) {
        parenView.addSubview(self)
        let top = NSLayoutConstraint(item: self,
                                     attribute: .top,
                                     relatedBy: .equal,
                                     toItem: searchBarView,
                                     attribute: .bottom,
                                     multiplier: 1,
                                     constant: 0)
        let left = NSLayoutConstraint(item: self,
                                      attribute: .left,
                                      relatedBy: .equal,
                                      toItem: parenView,
                                      attribute: .left,
                                      multiplier: 1,
                                      constant: 0)
        let right = NSLayoutConstraint(item: self,
                                       attribute: .right,
                                       relatedBy: .equal,
                                       toItem: parenView,
                                       attribute: .right,
                                       multiplier: 1,
                                       constant: 0)
        let bottom = NSLayoutConstraint(item: self,
                                        attribute: .bottom,
                                        relatedBy: .equal,
                                        toItem: parenView,
                                        attribute: .bottom,
                                        multiplier: 1,
                                        constant: 0)
        parenView.addConstraints([left, top, bottom, right])
    }

    func layoutStateChanged(_ newState: SearchBarViewLayoutState) {
        switch newState {
        case .expanded:
            self.isHidden = false
            self.alphaValue = 0

            // Animate
            NSAnimationContext.runAnimationGroup({ context in
                context.allowsImplicitAnimation = true
                context.duration = 0.22
                context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)

                self.alphaValue = 1
            }, completionHandler: nil)
        case .shrink:
            self.isHidden = false
            self.alphaValue = 1

            // Animate
            NSAnimationContext.runAnimationGroup({ context in
                context.allowsImplicitAnimation = true
                context.duration = 0.22
                context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)

                self.alphaValue = 0
            }, completionHandler: {
                self.isHidden = true
            })
        }
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
        self.collectionView.collectionViewLayout = flow
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
        guard let delegate = self.delegate else {
            return 0
        }
        return delegate.searchCollectionViewNumberOfPlace()
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
            guard let delegate = self.delegate else {
                return NSCollectionViewItem()
            }

            let placeObj = delegate.searchCollectionView(self, atIndex: indexPath)
            cell.configurePlaceCell(placeObj)
            return cell
    }
}

// MARK: - NSCollectionViewDelegate
extension SearchCollectionView: NSCollectionViewDelegate, NSCollectionViewDelegateFlowLayout {
}
