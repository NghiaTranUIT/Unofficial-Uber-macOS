//
//  UberAnnotation.swift
//  UberGo
//
//  Created by Nghia Tran on 6/29/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation
import Mapbox

protocol UberAnnotationType {

    var imageAnnotation: MGLAnnotationImage? { get }
    var calloutViewController: NSViewController? { get }
}

