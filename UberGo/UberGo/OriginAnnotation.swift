//
//  CircleShape.swift
//  UberGo
//
//  Created by Nghia Tran on 6/29/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation
import Mapbox
import UberGoCore

class OriginAnnotation: MGLPointAnnotation {

    // MARK: - Variable
    fileprivate var placeObj: PlaceObj!

    fileprivate lazy var _imageAnnotation: MGLAnnotationImage = {
        let image = NSImage(imageLiteralResourceName: "current_mark")
        return MGLAnnotationImage(image: image,
                                  reuseIdentifier: "current_mark")
    }()

    fileprivate lazy var _calloutController: NSViewController = {
        let controller = CalloutAnnotations(nibName: "CalloutAnnotations", bundle: nil)!
        controller.setupCallout(mode: .withTimeEstimation, timeObj: nil, placeObj: self.placeObj)
        return controller
    }()

    public func setupCallout(timeObj: TimeEstimateObj?) {
        guard let controller = self._calloutController as? CalloutAnnotations else { return }
        controller.setupCallout(mode: .withTimeEstimation, timeObj: timeObj, placeObj: placeObj)
    }

    // MARK: - Init
    public init(placeObj: PlaceObj) {
        self.placeObj = placeObj

        super.init()

        self.coordinate = placeObj.coordinate2D
        self.title = placeObj.name
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

// MARK: - UberAnnotationType
extension OriginAnnotation: UberAnnotationType {

    var imageAnnotation: MGLAnnotationImage? {
        return _imageAnnotation
    }

    var calloutViewController: NSViewController? {
        return _calloutController
    }
}
