//
//  Rx+PreviousValue.swift
//  UberGoCore
//
//  Created by Nghia Tran on 8/30/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation
import RxSwift

extension ObservableType {

    func withPrevious(startWith first: E) -> Observable<(E, E)> {
        return scan((first, first)) { ($0.1, $1) }.skip(1)
    }
}
