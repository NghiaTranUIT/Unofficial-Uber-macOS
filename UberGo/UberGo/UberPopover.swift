//
//  UberPopover.swift
//  UberGo
//
//  Created by Nghia Tran on 6/28/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import RxCocoa
import RxSwift
import UberGoCore

class UberPopover: NSPopover {

    // MARK: - Variable
    fileprivate let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    public let authenViewModel: AuthenticationViewModel
    fileprivate let viewModel: AppViewModel
    fileprivate let disposeBag = DisposeBag()

    fileprivate lazy var webviewController: WebViewController = self.lazyInitWebviewController()

    // Event monitor
    fileprivate lazy var eventMonitor: EventMonitor = self.initEventMonitor()

    // MARK: - Init
    init(appViewModel: AppViewModel) {
        viewModel = appViewModel

        // Web Handler - Incase need re-fresh or re-login
        authenViewModel = AuthenticationViewModel()

        super.init()
        initCommon()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public
    public func binding() {

        // Update Layout
        authenViewModel.output.authenticateStateDriver
            .drive(onNext: {[weak self] state in
                guard let `self` = self else { return }

                // Setup
                self.setupContentController(with: state)
            })
            .addDisposableTo(disposeBag)

        viewModel.output.popoverStateVariable.asDriver()
            .skip(1)
            .drive(onNext: {[unowned self] (state) in
                switch state {
                case .close:
                    self.close()
                case .open:
                    self.show()
                }
            }).addDisposableTo(disposeBag)
    }

    public func setupContentController(with state: AuthenticationState) {

        switch state {
        case .authenticated:
            contentViewController = MapViewController(nibName: "MapViewController", bundle: nil)

        case .unAuthenticated:
            let login = LoginViewController(nibName: "LoginViewController", bundle: nil)!
            login.viewModel = authenViewModel
            contentViewController = login
        }
    }

    public func startEventMonitor() {
        eventMonitor.start()
    }

    @objc func togglePopover() {
        if isShown {
            viewModel.input.actionPopoverPublish.onNext(.close)
        } else {
            viewModel.input.actionPopoverPublish.onNext(.open)
        }
    }

}

// MARK: - Private
extension UberPopover {

    fileprivate func initCommon() {

        if let button = statusItem.button {
            button.image = NSImage(imageLiteralResourceName: "StatusBarButtonImage")
            button.imagePosition = .imageLeft
            button.action = #selector(togglePopover)
            button.target = self
        }

        appearance = NSAppearance(named: NSAppearanceNameAqua)
        animates = false
        behavior = .transient
    }

    fileprivate func lazyInitWebviewController() -> WebViewController {
        return WebViewController.webviewControllerWith(WebViewMode.loginUber)
    }

    fileprivate func initEventMonitor() -> EventMonitor {
        return EventMonitor(mask: [NSEventMask.leftMouseDown,
                            NSEventMask.rightMouseDown]) { [weak self] _ in
                                guard let `self` = self else { return }
                                if self.isShown {
                                    self.viewModel.actionPopoverPublish.onNext(.close)
                                }
        }
    }

    internal override func close() {
        if isShown { return }

        super.close()
        eventMonitor.stop()
    }

    fileprivate func show() {

        NSRunningApplication.current().activate(options: NSApplicationActivationOptions.activateIgnoringOtherApps)

        guard let button = statusItem.button else {
            return
        }

        show(relativeTo: button.frame, of: button, preferredEdge: .minY)
        eventMonitor.start()
    }

}
