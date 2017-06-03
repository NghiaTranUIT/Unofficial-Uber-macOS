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
import OAuthSwift

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

        // listen to scheme url
        NSAppleEventManager.shared().setEventHandler(self, andSelector:#selector(AppDelegate.handleGetURL(event:withReplyEvent:)), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))

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

    func handleGetURL(event: NSAppleEventDescriptor!, withReplyEvent: NSAppleEventDescriptor!) {
        self.authenticationViewModel.input.uberCallbackPublish.onNext(event)
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
            let login = LoginViewController(nibName: "LoginViewController", bundle: nil)!
            login.viewModel = self.authenticationViewModel
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
