//
//  Rx+Optional.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/10/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public protocol OptionalType {
    associatedtype Wrapped
    var value: Wrapped? { get }
}

extension Optional: OptionalType {
    /// Cast `Optional<Wrapped>` to `Wrapped?`
    public var value: Wrapped? {
        return self
    }
}

public extension ObservableType where E: OptionalType {

    /**
     Unwraps and filters out `nil` elements.
     - returns: `Observable` of source `Observable`'s elements, with `nil` elements filtered out.
     */
    public func filterNil() -> Observable<E.Wrapped> {
        return self.flatMap { element -> Observable<E.Wrapped> in
            guard let value = element.value else {
                return Observable<E.Wrapped>.empty()
            }
            return Observable<E.Wrapped>.just(value)
        }
    }
}

public extension SharedSequenceConvertibleType where SharingStrategy == DriverSharingStrategy, E: OptionalType {

    /**
     Unwraps and filters out `nil` elements.
     - returns: `Driver` of source `Driver`'s elements, with `nil` elements filtered out.
     */
    public func filterNil() -> Driver<E.Wrapped> {
        return self.flatMap { element -> Driver<E.Wrapped> in
            guard let value = element.value else {
                return Driver<E.Wrapped>.empty()
            }
            return Driver<E.Wrapped>.just(value)
        }
    }
}
