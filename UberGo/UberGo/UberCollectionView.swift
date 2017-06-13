//
//  SearchCollectionView.swift
//  UberGo
//
//  Created by Nghia Tran on 6/8/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa

// MARK: - UberCollectionView
class UberCollectionView: NSCollectionView {

    // MARK: - Override
    // Flip macOS system coordinate 
    // to correspond with iOS
    override open var isFlipped: Bool {
        return true
    }
}
