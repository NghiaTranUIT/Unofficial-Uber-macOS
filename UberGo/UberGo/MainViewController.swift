//
//  MainViewController.swift
//  UberGo
//
//  Created by Nghia Tran on 10/30/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa
import UberGoCore

enum MapViewLayoutState {
    case expand
    case minimal
    case searchFullScreen
    case productSelection
    case tripFullActivity
    case tripMinimunActivity
}

class MainViewController: NSViewController {

    // MARK: - OUTLET
    @IBOutlet fileprivate weak var exitNavigateBtn: NSButton!
    @IBOutlet fileprivate weak var mapContainerView: NSView!
    @IBOutlet fileprivate weak var bottomBarView: NSView!
    @IBOutlet fileprivate weak var containerViewHeight: NSLayoutConstraint!
    @IBOutlet fileprivate weak var menuContainerView: NSView!
    @IBOutlet fileprivate weak var menuContainerViewOffset: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    // MARK: - Init
    public class func buildController(_ coordinator: ViewModelCoordinatorProtocol) -> MainViewController {
        let controller = MainViewController(nibName: "MainViewController", bundle: nil)!
        return controller
    }
}
