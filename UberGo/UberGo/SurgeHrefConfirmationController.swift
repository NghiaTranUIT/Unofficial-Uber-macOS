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

class SurgeHrefConfirmationController: NSViewController {

    // MARK: - OUTLET
    @IBOutlet fileprivate weak var webView: WKWebView!

    // MARK: - Private
    fileprivate var estimateObj: EstimateObj!

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()

        // Load
        guard let urlStr = self.estimateObj.surgePriceObj?.surgeConfirmationHref else {
            return
        }
        guard let url = URL(string: urlStr) else {
            return
        }

        self.webView.load(URLRequest(url: url))
    }

    // MARK: - Public
    public func configureWebView(with estimateObj: EstimateObj) {
        self.estimateObj = estimateObj
    }
}
