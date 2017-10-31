//
//  UberMapView+Hack.swift
//  UberGo
//
//  Created by Nghia Tran on 9/15/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Mapbox
import UberGoCore

extension UberMapView {

    func hideUnnecessaryUI() {

        // Hack
        let viewsNeedDelete = subviews.filter { (view) -> Bool in

            // Indicator and Logo
            if view is NSSlider || view is NSImageView || view is NSSegmentedControl {
                return true
            }

            return false
        }

        // Remove all
        viewsNeedDelete.forEach({ $0.isHidden = true })
    }
}
