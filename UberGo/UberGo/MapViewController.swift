//
//  MapViewController.swift
//  UberGo
//
//  Created by Nghia Tran on 6/2/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa
import UberGoCore

class MapViewController: NSViewController {

    // MARK: - Variable
    fileprivate var viewModel: MapViewModel!

    // MARK: - View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.viewModel = MapViewModel()
    }
    
}
