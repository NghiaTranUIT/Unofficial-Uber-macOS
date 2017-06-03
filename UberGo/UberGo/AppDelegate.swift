//
//  AppDelegate.swift
//  UberGo
//
//  Created by Nghia Tran on 5/30/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa
import UberGoCore

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {


    // MARK: - Variable
    fileprivate var viewModel: AppViewModel!
    fileprivate let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    fileprivate let popover = NSPopover()
    
    // MARK: - Action
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        self.viewModel = AppViewModel()
        
        // Setup
        self.setupPopover()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}

// MARK: - Private
extension AppDelegate {
    
    fileprivate func setupPopover() {
        
        if let button = statusItem.button {
            button.image = NSImage(named: "StatusBarButtonImage")
            button.imagePosition = .imageLeft
            button.action = #selector(togglePopover)
        }
        
        popover.contentViewController = LoginViewController(nibName: "LoginViewController", bundle: nil)
        popover.appearance = NSAppearance(named: NSAppearanceNameAqua)
        popover.animates = false
        popover.behavior = .transient

    }
    
    @objc fileprivate func togglePopover() {
        if self.popover.isShown {
            self.close()
        } else {
            self.show()
        }
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

