//
//  OauthWebViewHandler.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/28/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa
import OAuthSwift

public protocol OauthWebViewHandlerDelegate: class {
    func oauthVisibleController() -> NSViewController
    func oauthWebviewController(_ url: URL) -> NSViewController
}

open class OauthWebViewHandler: OAuthSwiftURLHandlerType {

    fileprivate var visibleController: NSViewController {
        return self.delegate!.oauthVisibleController()
    }

    fileprivate var observers = [String: AnyObject]()
    public weak var delegate: OauthWebViewHandlerDelegate?

    // delegates
    open var presentCompletion: (() -> Void)?
    open var dismissCompletion: (() -> Void)?

    public init() {

    }

    @objc open func handle(_ url: URL) {

        let webController = self.delegate!.oauthWebviewController(url)

        // present controller in main thread
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            self.visibleController.presentViewControllerAsSheet(webController)
        }

        let key = UUID().uuidString

        observers[key] = OAuthSwift.notificationCenter.addObserver(
            forName: NSNotification.Name.OAuthSwiftHandleCallbackURL,
            object: nil,
            queue: OperationQueue.main,
            using: { [weak self] _ in
                guard let `self` = self else { return }
                if let observer = `self`.observers[key] {
                    OAuthSwift.notificationCenter.removeObserver(observer)
                    `self`.observers.removeValue(forKey: key)
                }

                DispatchQueue.main.async { [weak self] in
                    guard let `self` = self else { return }
                    self.visibleController.dismissViewController(webController)
                }
            }
        )
    }
}
