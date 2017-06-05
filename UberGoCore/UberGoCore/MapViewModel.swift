//
//  MapViewModel.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/3/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation
import MapKit
import RxSwift
import RxOptional
import RxCocoa

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
    var errorLocationVariable: Variable<Error?> { get }
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
    fileprivate var mapManager = MapManager()

    // MARK: - Input
    public var getCurrentLocationPublish = PublishSubject<Void>()

    // MARK: - Output
    public var currentLocationDriver: Driver<CLLocation?> {
        return mapManager.currentLocationVariable.asDriver()
    }
    public var errorLocationVariable = Variable<Error?>(nil)

    // MARK: - Init
    public override init() {
        super.init()

        // Get current location
        let mapObser = self.getCurrentLocationPublish.flatMapLatest {[weak self] _ -> Observable<MapManagerResult> in
            guard let `self` = self else {
                return Observable.empty()
            }
            return self.mapManager.requestLocationObserver()
        }.share()

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


    }
}
