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
    fileprivate lazy var coordinator: ViewModelCoordinatorProtocol = self.initLayzViewModelCoordinator()
    fileprivate var popover: UberPopover!
    fileprivate let disposeBag = DisposeBag()

    // MARK: - Action
    func applicationDidFinishLaunching(_ aNotification: Notification) {

        // listen to scheme url
        let selector = #selector(AppDelegate.handleGetURL(event:withReplyEvent:))
        NSAppleEventManager.shared().setEventHandler(self, andSelector: selector,
                                                     forEventClass: AEEventClass(kInternetEventClass),
                                                     andEventID: AEEventID(kAEGetURL))

        popover = UberPopover(coordinator: coordinator)
        popover.binding()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    deinit {
        NotificationCenter.removeAllObserve(self)
    }

    @objc func handleGetURL(event: NSAppleEventDescriptor!, withReplyEvent: NSAppleEventDescriptor!) {
        guard let url = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue else {
            return
        }

        // Uber Surge
        if url.contains("uber-surge") {
            NotificationCenter.postNotificationOnMainThreadType(.handleSurgeCallback, object: event, userInfo: nil)
            return
        }

        // Uber Authentication
        UberAuth.share.callbackObserverPublish.onNext(event)
    }

    // MARK: - Debug
    @IBAction func currentTripStatusOnTap(_ sender: Any) {
        coordinator.appViewModel.input.currentTripStatusPublish.onNext(())
    }

    @IBAction func cancelCurrentTripOnTab(_ sender: Any) {
        coordinator.appViewModel.input.cancelCurrentTripPublish.onNext(())
    }

    @IBAction func updateStateOnTap(_ sender: NSMenuItem) {
        let status = TripObjStatus.createTripStatus(rawValue: sender.title)
        coordinator.appViewModel.input.updateStatusTripPublish.onNext(status)
    }

    @IBAction func logoutUberOnTap(_ sender: NSMenuItem) {
        UberAuth.share.logout()
    }

    @IBAction func profileBtnOnTap(_ sender: Any) {
        NotificationCenter.postNotificationOnMainThreadType(.openCloseMenu)
    }
}

// MARK: - Coordinator
extension AppDelegate {
    fileprivate func initLayzViewModelCoordinator() -> ViewModelCoordinator {
        return ViewModelCoordinator.defaultUber()
    }
}
