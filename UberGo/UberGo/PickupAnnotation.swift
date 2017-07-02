//
//  PickupAnnotation.swift
//  UberGo
//
//  Created by Nghia Tran on 6/29/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation
import Mapbox

class PickupAnnotation: MGLPointAnnotation {

    // MARK: - Variable
    public lazy var image: MGLAnnotationImage = {
        let image = NSImage(imageLiteralResourceName: "pickup_mark")
        return MGLAnnotationImage(image: image,
                                  reuseIdentifier: "pickup_mark")
    }()
}

// MARK: - UberAnnotationType
extension PickupAnnotation: UberAnnotationType {

    var imageAnnotation: MGLAnnotationImage? {
        return image
    }

    var calloutViewController: NSViewController? {
        return nil
    }
}
