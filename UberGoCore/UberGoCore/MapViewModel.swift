//
//  MapViewModel.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/3/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation
import MapKit
import RxCocoa
import RxOptional
import RxSwift

// MARK: - Protocol
public protocol MapViewModelProtocol {

    var input: MapViewModelInput { get }
    var output: MapViewModelOutput { get }
}

public protocol MapViewModelInput {

    var getCurrentLocationPublish: PublishSubject<Void> { get }
}

public protocol MapViewModelOutput {

    var currentLocationDriver: Driver<CLLocation?> { get }
    var nearestPlaceDriver: Driver<PlaceObj> { get }
    var errorLocationVariable: Variable<Error?> { get }
    var productsVariable: Variable<[ProductObj]> { get }
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
    fileprivate var mapManager = MapService()

    // MARK: - Input
    public var getCurrentLocationPublish = PublishSubject<Void>()

    // MARK: - Output
    public var currentLocationDriver: Driver<CLLocation?> {
        return mapManager.currentLocationVariable.asDriver()
    }
    public var errorLocationVariable = Variable<Error?>(nil)
    public var productsVariable = Variable<[ProductObj]>([])
    public var nearestPlaceDriver: Driver<PlaceObj> {
        return self.mapManager.nearestPlaceObverser.asDriver(onErrorJustReturn: PlaceObj.unknowPlace)
    }

    // MARK: - Init
    public override init() {
        super.init()

        // Get current location
        let mapObser = self.getCurrentLocationPublish
        .flatMapLatest {[weak self] _ -> Observable<MapServiceResult> in
            guard let `self` = self else {
                return Observable.empty()
            }
            return self.mapManager.requestLocationObserver()
        }.share()

        // Error
        mapObser
            .map({ (result) -> Error? in
                switch result {
                case .error(let error):
                    return error
                default:
                    return nil
                }
            })
            .filterNil()
            .observeOn(MainScheduler.instance)
            .bind(to: self.errorLocationVariable)
            .addDisposableTo(self.disposeBag)

        // Products
        let location = CLLocationCoordinate2D(latitude: 10.78492533, longitude: 106.70296385)
        Observable<[ProductObj]>.just([])
        .flatMapLatest { _ -> Observable<[ProductObj]> in
            let param = UberProductsRequestParam(location: location)
            return UberProductsRequest(param).toObservable()
        }
        .bind(to: self.productsVariable)
        .addDisposableTo(self.disposeBag)
    }
}
