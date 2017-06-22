//
//  PaymentMethodViewModel.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/22/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import RxSwift

public protocol PaymentMethodViewModelViewModel {

    var input: PaymentMethodViewModelInput { get }
    var output: PaymentMethodViewModelOutput { get }
}

public protocol PaymentMethodViewModelInput {

}

public protocol PaymentMethodViewModelOutput {

    var paymentMethodObjVar: Variable<PaymentObj?> { get }
}

open class PaymentMethodViewModel: BaseViewModel,
                                   PaymentMethodViewModelViewModel,
                                   PaymentMethodViewModelInput,
                                   PaymentMethodViewModelOutput {

    // MARK: - View Model
    public var input: PaymentMethodViewModelInput { return self }
    public var output: PaymentMethodViewModelOutput { return self }

    // MARK: - Input

    // MARK: - Output
    public var paymentMethodObjVar: Variable<PaymentObj?> {
        return UserObj.currentUser!.paymentMethodObjVar
    }

    // MARK: - Init
    public override init() {
        super.init()

        // Binding

    }
}
