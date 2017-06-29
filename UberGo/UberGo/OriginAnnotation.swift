//
//  CircleShape.swift
//  UberGo
//
//  Created by Nghia Tran on 6/29/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation
import Mapbox

class OriginAnnotation: MGLPointAnnotation {

    // MARK: - Variable
    public lazy var imageAnnotation: MGLAnnotationImage = {
        let image = NSImage(imageLiteralResourceName: "current_mark_normal")
        return MGLAnnotationImage(image: image,
                                  reuseIdentifier: "current_mark_normal")
    }()

    public lazy var imageDirectionAnnotation: MGLAnnotationImage = {
        let image = NSImage(imageLiteralResourceName: "current_mark")
        return MGLAnnotationImage(image: image,
                                  reuseIdentifier: "current_mark")
    }()
}
