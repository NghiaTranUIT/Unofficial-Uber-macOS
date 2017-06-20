//
//  UberServiceViewModel.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/20/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import CoreLocation
import Foundation
import RxCocoa
import RxSwift

public protocol UberServiceViewModelProtocol {

    var input: UberServiceViewModelInput { get }
    var output: UberServiceViewModelOutput { get }
}

public protocol UberServiceViewModelInput {

    var selectedPlaceObserve: PublishSubject<(PlaceObj, CLLocation)> { get }
}

public protocol UberServiceViewModelOutput {

    var availableGroupProductsDriver: Driver<[GroupProductObj]>! { get }
    var isLoadingAvailableProductPublisher: PublishSubject<Bool> { get }
    var selectedGroupProduct: Variable<GroupProductObj?> { get }
    var selectedProduct: Variable<ProductObj?> { get }
}

open class UberServiceViewModel: BaseViewModel,
                                 UberServiceViewModelProtocol,
                                 UberServiceViewModelInput,
                                 UberServiceViewModelOutput {

    // MARK: - View Model
    public var input: UberServiceViewModelInput { return self }
    public var output: UberServiceViewModelOutput { return self }

    // MARK: - Input
    public var selectedPlaceObserve = PublishSubject<(PlaceObj, CLLocation)>()

    // MARK: - Output
    public var availableGroupProductsDriver: Driver<[GroupProductObj]>!
    public var isLoadingAvailableProductPublisher = PublishSubject<Bool>()
    public let selectedGroupProduct = Variable<GroupProductObj?>(nil)
    public let selectedProduct = Variable<ProductObj?>(nil)

    // MARK: - Variable
    fileprivate var uberService = UberService()

    // MARK: - Init
    override public init() {
        super.init()

        // Get available Product + Estimate price
        let selectionShared =
            self.selectedPlaceObserve
            .do(onNext: {[unowned self] _ in
                self.isLoadingAvailableProductPublisher.onNext(true)
            })
            .flatMapLatest { data -> Observable<[ProductObj]> in
                let current = data.1
                return self.uberService.productsWithEstimatePriceObserver(from: current.coordinate,
                                                                          to: data.0.coordinate2D!)
            }
            .map({ GroupProductObj.mapProductGroups(from: $0) })
            .share()

        // Data
        self.availableGroupProductsDriver = selectionShared
                                            .asDriver(onErrorJustReturn: [])

        // Default selection
        selectionShared.map { (groups) -> GroupProductObj in
            return groups.first!
        }.bind(to: self.selectedGroupProduct)
        .addDisposableTo(self.disposeBag)

        selectionShared.map { (groups) -> ProductObj in
            return groups.first!.productObjs.first!
        }.bind(to: self.selectedProduct)
        .addDisposableTo(self.disposeBag)
    }
}
