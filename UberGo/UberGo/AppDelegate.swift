//
//  AppDelegate.swift
//  UberGo
//
//  Created by Nghia Tran on 5/30/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa
import OAuthSwift
import RxSwift
import UberGoCore

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: - Variable
    fileprivate var viewModel = AppViewModel()

    fileprivate var popover: UberPopover!
    fileprivate let disposeBag = DisposeBag()

    // MARK: - Action
    func applicationDidFinishLaunching(_ aNotification: Notification) {

        // listen to scheme url
        let selector = #selector(AppDelegate.handleGetURL(event:withReplyEvent:))
        NSAppleEventManager.shared().setEventHandler(self, andSelector: selector,
                                                     forEventClass: AEEventClass(kInternetEventClass),
                                                     andEventID: AEEventID(kAEGetURL))

        self.popover = UberPopover(appViewModel: self.viewModel)
        self.popover.binding()
        self.popover.startEventMonitor()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    deinit {
        NotificationService.removeAllObserve(self)
    }

    func handleGetURL(event: NSAppleEventDescriptor!, withReplyEvent: NSAppleEventDescriptor!) {
        guard let url = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue else {
            return
        }

        // Uber Surge
        if url.contains("uber-surge") {
            NotificationService.postNotificationOnMainThreadType(.handleSurgeCallback, object: event, userInfo: nil)
            return
        }

        // Uber Authentication
        self.popover.authenViewModel.input.uberCallbackPublish.onNext(event)
    }

    // MARK: - Debug
    @IBAction func currentTripStatusOnTap(_ sender: Any) {
        self.viewModel.input.currentTripStatusPublish.onNext()
    }

    @IBAction func cancelCurrentTripOnTab(_ sender: Any) {
        self.viewModel.input.cancelCurrentTripPublish.onNext()
    }

    @IBAction func updateStateOnTap(_ sender: NSMenuItem) {
        let status = TripObjStatus.createTripStatus(rawValue: sender.title)
        self.viewModel.input.updateStatusTripPublish.onNext(status)
    }

    @IBAction func logoutUberOnTap(_ sender: NSMenuItem) {

        // Logout
        UberAuth.share.logout()

        // Layout
        self.popover.setupContentController(with: .unAuthenticated)
    }

}

// MARK: - Private
extension AppDelegate {
}
