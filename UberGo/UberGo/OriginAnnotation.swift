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
    fileprivate lazy var _imageAnnotation: MGLAnnotationImage = {
        let image = NSImage(imageLiteralResourceName: "current_mark")
        return MGLAnnotationImage(image: image,
                                  reuseIdentifier: "current_mark")
    }()

    fileprivate lazy var _calloutController: NSViewController = {
        return CalloutAnnotations(nibName: "CalloutAnnotations", bundle: nil)!
    }()

    public func setupCallout(_ mode: CalloutAnnotationsLayoutMode, timeObj: TimeEstimateObj) {
        guard let controller = self._calloutController as? CalloutAnnotations else { return }
        controller.setupCallout(mode: mode, timeObj: timeObj, destinationObj: nil)
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
