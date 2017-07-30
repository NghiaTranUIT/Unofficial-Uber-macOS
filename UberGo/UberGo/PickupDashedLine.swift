//
//  DashedLine.swift
//  UberGo
//
//  Created by Nghia Tran on 7/30/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation
import Mapbox

class PickupDashedLine: MGLLineStyleLayer {

    public class func defaultDashedLine(with source: MGLShapeSource) -> PickupDashedLine {

        // Create new layer for the line
        let dashedLayer = PickupDashedLine(identifier: "polyline-dash", source: source)
        dashedLayer.lineJoin = MGLStyleValue(rawValue: NSValue(mglLineJoin: .round))
        dashedLayer.lineCap = MGLStyleValue(rawValue: NSValue(mglLineCap: .round))
        dashedLayer.lineColor = MGLStyleValue(rawValue: .black)

        // Dash pattern in the format [dash, gap, dash, gap, ...].
        // You’ll want to adjust these values based on the line cap style.
        dashedLayer.lineDashPattern = MGLStyleValue(rawValue: [0, 2])

        // Use a style function to smoothly adjust the line width from 2pt to 20pt
        // between zoom levels 14 and 18.
        // The `interpolationBase` parameter allows the values to interpolate along an exponential curve.
//        let options = [MGLStyleFunctionOption.defaultValue: MGLConstantStyleValue<NSNumber>(rawValue: 1.5)]
//        dashedLayer.lineWidth = MGLStyleValue(interpolationMode: .exponential,
//                                        cameraStops: [14: MGLStyleValue<NSNumber>(rawValue: 2),
//                                                      18: MGLStyleValue<NSNumber>(rawValue: 20)],
//                                        options: options)
        dashedLayer.lineWidth = MGLConstantStyleValue<NSNumber>(rawValue: 6)
        return dashedLayer
    }
}
