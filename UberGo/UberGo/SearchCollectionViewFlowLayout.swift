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
    fileprivate var sizeCell = CGSize.zero
    fileprivate var cellsAttributes: [NSCollectionViewLayoutAttributes] = []
    fileprivate var contentSize = CGSize.zero
    fileprivate var itemCount = 0

    //
    // MARK: - Init
    public override init() {
        super.init()

        self.scrollDirection = .vertical
        self.minimumLineSpacing = 0
        self.minimumInteritemSpacing = 0
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //
    // MARK: - Override
    fileprivate func updateDataSource() {
        guard let collectionView = self.collectionView else { return }

        // Cound
        self.itemCount = self.collectionView?.dataSource?.collectionView(collectionView, numberOfItemsInSection: 0) ?? 0

        // Size
        let sizeScreen = collectionView.frame.size
        self.sizeCell = CGSize(width: sizeScreen.width, height: 57)
    }

    override open func prepare() {
        super.prepare()

        // Update data
        self.updateDataSource()

        // Prepare data
        var cell: [NSCollectionViewLayoutAttributes] = []

        for i in 0..<self.itemCount {

            let x: CGFloat = 0
            let y = CGFloat(i) * self.sizeCell.height
            let indexPath = IndexPath(item: i, section: 0)

            // Create attribute
            let att = NSCollectionViewLayoutAttributes(forItemWith: indexPath)
            att.frame = CGRect(x: x, y: y, width: self.sizeCell.width, height: self.sizeCell.height)

            // Append
            cell.append(att)
        }

        //
        self.contentSize = self.calculateContentSize()
        self.cellsAttributes = cell
    }

    fileprivate func calculateContentSize() -> CGSize {
        guard let collectionView = self.collectionView else {
            return CGSize.zero
        }

        let height = CGFloat(self.itemCount) * self.sizeCell.height
        return CGSize(width: collectionView.frame.width, height: height)
    }

    //
    // MARK: - Override
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {
        return self.cellsAttributes[indexPath.item]
    }

    override open func layoutAttributesForElements(in rect: CGRect) -> [NSCollectionViewLayoutAttributes] {

        var cells: [NSCollectionViewLayoutAttributes] = []

        // Cell
        for att in self.cellsAttributes {
            if att.frame.intersects(rect) {
                cells.append(att)
            }
        }

        return cells
    }

    override open var collectionViewContentSize: CGSize {
        print("collectionViewContentSize = \(self.contentSize)")
        return self.contentSize
    }
}
