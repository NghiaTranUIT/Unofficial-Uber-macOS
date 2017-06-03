//
//  AppViewModel.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/1/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation

// MARK: - Protocol 
public protocol AppViewModelProtocol {

    var input: AppViewModelInput { get }
    var output: AppViewModelOutput { get }
}

public protocol AppViewModelInput {

}

public protocol AppViewModelOutput {

}

// MARK: - App ViewModel
open class AppViewModel: BaseViewModel, AppViewModelProtocol, AppViewModelInput, AppViewModelOutput {

    // MARK: - View model
    public var input: AppViewModelInput { return self }
    public var output: AppViewModelOutput { return self }

    // MARK: - Init
    public override init() {

    }
}
