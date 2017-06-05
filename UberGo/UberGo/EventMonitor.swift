//
//  EventMonitor.swift
//  UberGo
//
//  Created by Nghia Tran on 6/4/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa
import Foundation

typealias EventMonitorHandler = (NSEvent?) -> Void

class EventMonitor {

    // MARK: - Variable
    private var monitor: Any?
    private let mask: NSEventMask
    private let handler: EventMonitorHandler

    public init(mask: NSEventMask, handler: @escaping EventMonitorHandler) {
        self.mask = mask
        self.handler = handler
    }

    deinit {
        stop()
    }

    public func start() {
        self.monitor = NSEvent.addGlobalMonitorForEvents(matching: self.mask, handler: self.handler)
    }

    public func stop() {
        if self.monitor != nil {
            NSEvent.removeMonitor(self.monitor!)
            self.monitor = nil
        }
    }
}
