//
//  CenterHorizontalFlowLayout.swift
//  UberGo
//
//  Created by Nghia Tran on 6/18/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa

class CenterHorizontalFlowLayout: NSCollectionViewFlowLayout {

    // MARK: - Variable
    fileprivate var sizeCell = CGSize(width: 124, height: 151)
    fileprivate var cellsAttributes: [NSCollectionViewLayoutAttributes] = []
    fileprivate var contentSize = CGSize.zero
    fileprivate var itemCount = 0

    // MARK: - Init
    public override init() {
        super.init()

        scrollDirection = .horizontal
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Override
    fileprivate func updateDataSource() {
        guard let collectionView = collectionView else { return }
        itemCount = collectionView.dataSource?.collectionView(collectionView, numberOfItemsInSection: 0) ?? 0
    }

    override open func prepare() {
        super.prepare()

        // Update data
        updateDataSource()

        // Prepare data
        var cell: [NSCollectionViewLayoutAttributes] = []

        // Origin position
        let haflfContentSize = (sizeCell.width * CGFloat(itemCount)) / 2.0
        let halfBound = collectionView!.bounds.width / 2.0
        let padding: CGFloat = halfBound - haflfContentSize

        for i in 0..<itemCount {

            let y: CGFloat = 0
            let x = padding + CGFloat(i) * sizeCell.width
            let indexPath = IndexPath(item: i, section: 0)

            // Create attribute
            let att = NSCollectionViewLayoutAttributes(forItemWith: indexPath)
            att.frame = CGRect(x: x, y: y, width: sizeCell.width, height: sizeCell.height)

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

        let width = CGFloat(itemCount) * sizeCell.width
        if width < collectionView.frame.width {
            return collectionView.bounds.size
        }
        return CGSize(width: width, height: collectionView.frame.height)
    }

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
