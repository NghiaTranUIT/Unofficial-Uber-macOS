//
//  NSView+Identity.swift
//  UberGo
//
//  Created by Nghia Tran on 6/5/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa
import Foundation

// MARK: - BundleType
public enum BundleType {
    case app
    case core

    public var bundleName: String {
        switch self {
        case .app:
            return "com.fe.UberGo"
        case .core:
            return "com.fe.UberGoCore"
        }
    }
}

// MARK: - Identifier
// Easily to get ViewID and XIB file
public protocol Identifier {

    // ID view
    static var identifierView: String { get }

    // XIB - init XIB from identifierView
    static func xib(with bundleType: BundleType) -> NSNib?
}

// MARK: - Default Extension
public extension Identifier {

    // ID View
    static var identifierView: String {
        return String(describing: self)
    }

    // XIB
    static func xib(with bundleType: BundleType) -> NSNib? {
        let bundle = Bundle(identifier: bundleType.bundleName)
        return NSNib(nibNamed: NSNib.Name(rawValue: self.identifierView), bundle: bundle)
    }
}

// MARK: - Default Implementation for Identifier
extension NSView: Identifier {}
extension NSMenu: Identifier {}
