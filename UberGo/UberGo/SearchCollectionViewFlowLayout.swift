//
//  SearchCollectionViewFlowLayout.swift
//  UberGo
//
//  Created by Nghia Tran on 6/8/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa

class SearchCollectionViewFlowLayout: NSCollectionViewFlowLayout {

    //
    // MARK: - Variable
    fileprivate var cellsAttributes: [NSCollectionViewLayoutAttributes] = []
    fileprivate var contentSize = CGSize.zero
    fileprivate var itemCount = 0

    //
    // MARK: - Init
    public override init() {
        super.init()

        scrollDirection = .vertical
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //
    // MARK: - Override
    fileprivate func updateDataSource() {
        guard let collectionView = collectionView else { return }

        // Cound
        itemCount = collectionView.dataSource?.collectionView(collectionView, numberOfItemsInSection: 0) ?? 0
    }

    override open func prepare() {
        super.prepare()

        // Update data
        updateDataSource()

        // Prepare data
        var cell: [NSCollectionViewLayoutAttributes] = []

        for i in 0..<itemCount {

            let x: CGFloat = 0
            let y = CGFloat(i) * itemSize.height
            let indexPath = IndexPath(item: i, section: 0)

            // Create attribute
            let att = NSCollectionViewLayoutAttributes(forItemWith: indexPath)
            att.frame = CGRect(x: x, y: y, width: itemSize.width, height: itemSize.height)

            // Append
            cell.append(att)
        }

        //
        contentSize = calculateContentSize()
        cellsAttributes = cell
    }

    fileprivate func calculateContentSize() -> CGSize {
        guard let collectionView = collectionView else {
            return CGSize.zero
        }

        let height = CGFloat(itemCount) * itemSize.height
        return CGSize(width: collectionView.frame.width, height: height)
    }

    //
    // MARK: - Override
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {
        return cellsAttributes[indexPath.item]
    }

    override open func layoutAttributesForElements(in rect: CGRect) -> [NSCollectionViewLayoutAttributes] {

        var cells: [NSCollectionViewLayoutAttributes] = []

        // Cell
        for att in cellsAttributes {
            if att.frame.intersects(rect) {
                cells.append(att)
            }
        }

        return cells
    }

    override open var collectionViewContentSize: CGSize {
        return contentSize
    }
}
