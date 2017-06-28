//
//  SurgeHrefConfirmationController.swift
//  UberGo
//
//  Created by Nghia Tran on 6/21/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa
import UberGoCore
import WebKit

enum WebViewMode {
    case surgeConfirmation
    case loginUber
    case none
}

class WebViewController: NSViewController {

    // MARK: - OUTLET
    @IBOutlet fileprivate weak var webView: WKWebView!

    // MARK: - Variable
    public fileprivate(set) var mode: WebViewMode = .none
    public var data: Any?

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()

        self.loadWebview()
    }

    // MARK: - Public
    public class func webviewControllerWith(_ mode: WebViewMode) -> WebViewController {
        let controller = WebViewController(nibName: "WebViewController", bundle: nil)!
        controller.mode = mode
        return controller
    }

    fileprivate func loadWebview() {

        switch self.mode {
        case .surgeConfirmation:

            guard let surgePriceObj = data as? SurgePriceObj else { return }
            guard let urlStr = surgePriceObj.surgeConfirmationHref else { return }
            guard let url = URL(string: urlStr) else { return }
            self.webView.load(URLRequest(url: url))

        case .loginUber:
            guard let url = data as? URL else { return }
            self.webView.title = "Login"
            self.webView.load(URLRequest(url: url))

        case .none:
            break
        }
    }
}
