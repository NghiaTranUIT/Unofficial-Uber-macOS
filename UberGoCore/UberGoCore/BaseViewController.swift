//
//  BaseViewController.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/3/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa
import RxSwift

open class BaseViewController: NSViewController {

    public let disposeBag = DisposeBag()

    override open func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
}
