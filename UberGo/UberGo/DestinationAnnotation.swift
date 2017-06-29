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
    public lazy var imageAnnotation: MGLAnnotationImage = {
        let image = NSImage(imageLiteralResourceName: "destination_mark")
        return MGLAnnotationImage(image: image,
                                  reuseIdentifier: "destination_mark")
    }()
}
