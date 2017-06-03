//
//  AppDelegate.swift
//  UberGo
//
//  Created by Nghia Tran on 5/30/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa
import UberGoCore
import RxSwift

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {


    // MARK: - Variable
    fileprivate var viewModel: AppViewModel!
    fileprivate var authenticationViewModel: AuthenticationViewModel!
    fileprivate let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    fileprivate let popover = NSPopover()
    fileprivate let disposeBag = DisposeBag()

    // MARK: - Action
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        self.viewModel = AppViewModel()
        self.authenticationViewModel = AuthenticationViewModel()

        self.viewModel.output.popoverStateVariable.asDriver().drive(onNext: {[unowned self] (state) in
            switch state {
            case .close:
                self.close()
            case .open:
                self.show()
            }
        }).addDisposableTo(self.disposeBag)

        self.authenticationViewModel.output.authenticateStateDriver.drive(onNext: {[unowned self] state in

            // Setup
            self.setupPopover(with: state)
        })
        .addDisposableTo(self.disposeBag)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}

// MARK: - Private
extension AppDelegate {
    
    fileprivate func setupPopover(with state: AuthenticationState) {
        
        if let button = statusItem.button {
            button.image = NSImage(named: "StatusBarButtonImage")
            button.imagePosition = .imageLeft
            button.action = #selector(togglePopover)
        }

        popover.appearance = NSAppearance(named: NSAppearanceNameAqua)
        popover.animates = false
        popover.behavior = .transient

        switch state {
        case .authenticated:
            popover.contentViewController = MapViewController(nibName: "MapViewController", bundle: nil)
        case .unAuthenticated:
            let login = LoginViewController(nibName: "LoginViewController", viewModel: self.authenticationViewModel)
            popover.contentViewController = login

        }

    }
    
    @objc fileprivate func togglePopover() {
        self.viewModel.input.switchPopoverPublish.onNext()
    }
    
    fileprivate func close() {
        if self.popover.isShown {
            return
        }
        
        self.popover.close()
    }
    
    fileprivate func show() {
        
        NSRunningApplication.current().activate(options: NSApplicationActivationOptions.activateIgnoringOtherApps)
        
        guard let button = self.statusItem.button else {
            return
        }
        
        self.popover.show(relativeTo: button.frame, of: button, preferredEdge: .minY)
    }
}
