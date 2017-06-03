//
//  MapViewModel.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/3/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation
import RxSwift

// MARK: - Protocol
public protocol MapViewModelProtocol {

    var input: MapViewModelInput { get }
    var output: MapViewModelOutput { get }
}

public protocol MapViewModelInput {

}

public protocol MapViewModelOutput {

}

// MARK: - View Model
open class MapViewModel: BaseViewModel,
                        MapViewModelProtocol,
                        MapViewModelInput,
                        MapViewModelOutput {

    // MARK: - Protocol
    public var input: MapViewModelInput { return self }
    public var output: MapViewModelOutput { return self }

    // MARK: - Variable

    // MARK: - Input

    // MARK: - Output

    // MARK: - Init
    public override init() {
    }
}
