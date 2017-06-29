//
//  DestinationAnnotation.swift
//  UberGo
//
//  Created by Nghia Tran on 6/29/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation
import Mapbox

class DestinationAnnotation: MGLPointAnnotation {

    // MARK: - Variable

    fileprivate lazy var _imageAnnotation: MGLAnnotationImage = {
        let image = NSImage(imageLiteralResourceName: "destination_mark")
        return MGLAnnotationImage(image: image,
                                  reuseIdentifier: "destination_mark")
    }()

    fileprivate lazy var _calloutController: NSViewController = {
        return CalloutAnnotations(nibName: "CalloutAnnotations", bundle: nil)!
    }()
}

// MARK: - UberAnnotationType
extension DestinationAnnotation: UberAnnotationType {

    var imageAnnotation: MGLAnnotationImage? {
        return _imageAnnotation
    }

    var calloutViewController: NSViewController? {
        return _calloutController
    }
}
