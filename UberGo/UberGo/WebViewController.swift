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

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Public
    public class func webviewControllerWith(_ mode: WebViewMode) -> WebViewController {

        switch mode {
        case .surgeConfirmation:
            let controller = WebViewController(nibName: "WebViewController", bundle: nil)!
            controller.mode = .surgeConfirmation
            return controller
        case .loginUber:
            break
        case .none:
            break
        }

        fatalError()
    }

    public func loadWebview(data: Any) {

        switch self.mode {
        case .surgeConfirmation:

            guard let surgePriceObj = data as? SurgePriceObj else { return }
            guard let urlStr = surgePriceObj.surgeConfirmationHref else { return }
            guard let url = URL(string: urlStr) else { return }
            self.webView.load(URLRequest(url: url))

        case .loginUber:
            break

        case .none:
            break
        }
    }
}
