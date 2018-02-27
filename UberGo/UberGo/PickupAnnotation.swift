//
//  PickupAnnotation.swift
//  UberGo
//
//  Created by Nghia Tran on 6/29/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation
import Mapbox
import UberGoCore

class PickupAnnotation: MGLPointAnnotation {

    // MARK: - Variable
    public lazy var image: MGLAnnotationImage = {
        let image = NSImage(imageLiteralResourceName: "pickup_mark")
        return MGLAnnotationImage(image: image,
                                  reuseIdentifier: "pickup_mark")
    }()

    // MARK: - Variable
    fileprivate var pickup: PickupPointObj!

    fileprivate lazy var _calloutController: NSViewController = {
        let controller = CalloutAnnotations(nibName: NSNib.Name(rawValue: "CalloutAnnotations"), bundle: nil)
        controller.setupPickupPointCallout(self.pickup)
        return controller
    }()

    // MARK: - Init
    public init(pickup: PickupPointObj) {
        self.pickup = pickup

        super.init()

        self.coordinate = pickup.coordinate
        self.title = pickup.name ?? "Unknown"
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

// MARK: - UberAnnotationType
extension PickupAnnotation: UberAnnotationType {

    var imageAnnotation: MGLAnnotationImage? {
        return image
    }

    var calloutViewController: NSViewController? {
        return _calloutController
    }
}
