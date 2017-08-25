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
    fileprivate let authenViewModel: AuthenticationViewModelProtocol
    fileprivate let viewModel: AppViewModelProtocol
    fileprivate let disposeBag = DisposeBag()

    fileprivate lazy var webviewController: WebViewController = self.lazyInitWebviewController()

    // Event monitor
    fileprivate lazy var eventMonitor: EventMonitor = self.initEventMonitor()

    // MARK: - Init
    init(appViewModel: AppViewModelProtocol,
         authenViewModel: AuthenticationViewModelProtocol) {
        viewModel = appViewModel
        self.authenViewModel = authenViewModel

        super.init()
        delegate = self
        initCommon()
    }

    convenience init(coordinator: ViewModelCoordinator) {
        self.init(appViewModel: coordinator.appViewModel,
                  authenViewModel: coordinator.authenViewModel)
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
            .drive(onNext: {[weak self] (state) in
                guard let `self` = self else { return }
                switch state {
                case .close:
                    self.handleClose()
                case .open:
                    self.handleShow()
                }
            }).addDisposableTo(disposeBag)
    }

    fileprivate func setupContentController(with state: AuthenticationState) {

        switch state {
        case .authenticated:
            contentViewController = MapViewController(nibName: "MapViewController", bundle: nil)

        case .unAuthenticated:
            let login = LoginViewController(nibName: "LoginViewController", bundle: nil)!
            login.viewModel = authenViewModel
            contentViewController = login
        }
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
        behavior = .applicationDefined
    }

    fileprivate func lazyInitWebviewController() -> WebViewController {
        return WebViewController.webviewControllerWith(WebViewMode.loginUber)
    }

    fileprivate func initEventMonitor() -> EventMonitor {
        return EventMonitor(mask: [NSEventMask.leftMouseDown,
                            NSEventMask.rightMouseDown]) { [weak self] _ in
                                guard let `self` = self else { return }
                                Logger.info("Event Monitor fired")
                                if self.isShown {
                                    self.viewModel.actionPopoverPublish.onNext(.close)
                                }
        }
    }

    fileprivate func handleClose() {
        if !isShown { return }
        performClose(nil)
        eventMonitor.stop()
    }

    fileprivate func handleShow() {

        NSRunningApplication.current().activate(options: NSApplicationActivationOptions.activateIgnoringOtherApps)

        guard let button = statusItem.button else {
            return
        }

        show(relativeTo: button.frame, of: button, preferredEdge: .minY)
        eventMonitor.start()
    }
}

extension UberPopover: NSPopoverDelegate {

    func popoverWillClose(_ notification: Notification) {
        guard let contentViewController = self.contentViewController else { return }
        guard let presenteds = contentViewController.presentedViewControllers else { return }

        // Dismiss
        presenteds.forEach({ (controller) in
            contentViewController.dismissViewController(controller)
        })
    }
}
