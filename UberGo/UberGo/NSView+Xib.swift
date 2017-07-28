//
//  NSView+Xib.swift
//  UberGo
//
//  Created by Nghia Tran on 6/5/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation

//
// MARK: - Extension to help initial view from nib easier
// The ID of view my be same name of view
public protocol XIBInitializable {

    associatedtype XibType

    static func viewFromNib(with bundle: BundleType) -> XibType?
}

//
// MARK: - Default Extension
public extension XIBInitializable where Self: Identifier {

    static func viewFromNib(with bundle: BundleType) -> XibType? {

        var topViews: NSArray? = []

        _ = self.xib(with: bundle)?.instantiate(withOwner: self, topLevelObjects: &topViews!)

        for subView in topViews! {
            if let innerView = subView as? XibType {
                return innerView
            }
        }

        return nil
    }
}
