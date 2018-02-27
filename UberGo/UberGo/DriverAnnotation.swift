//
//  DriverAnnotation.swift
//  UberGo
//
//  Created by Nghia Tran on 9/7/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation
import Mapbox
import UberGoCore

class DriverAnnotation: MGLPointAnnotation {

    // MARK: - Variable
    public lazy var image: MGLAnnotationImage = {
        let image = NSImage(imageLiteralResourceName: "driver_mark")
        return MGLAnnotationImage(image: image,
                                  reuseIdentifier: "driver_mark")
    }()

    // MARK: - Variable
    fileprivate var driverObj: DriverObj!
    fileprivate var vehicleObj: VehicleObj!
    fileprivate var driverLocation: UberCoordinateObj!

    fileprivate lazy var _calloutController: NSViewController = {
        let controller = CalloutAnnotations(nibName: NSNib.Name(rawValue: "CalloutAnnotations"), bundle: nil)
        controller.setupCallout(mode: .noTimeEstimation, timeETA: nil, calloutTitle: self.title)
        return controller
    }()

    // MARK: - Init
    public init?(tripObj: TripObj) {
        guard let driverObj = tripObj.driver else { return nil }
        guard let driverLocation = tripObj.location else { return nil }
        guard let vehicleObj = tripObj.vehicle else { return nil }

        self.driverObj = driverObj
        self.driverLocation = driverLocation
        self.vehicleObj = vehicleObj

        super.init()

        self.coordinate = driverLocation.coordinate
        self.title = "\(driverObj.name) - \(vehicleObj.model) \(vehicleObj.licensePlate)"
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

// MARK: - UberAnnotationType
extension DriverAnnotation: UberAnnotationType {

    var imageAnnotation: MGLAnnotationImage? {
        return image
    }

    var calloutViewController: NSViewController? {
        return _calloutController
    }
}
