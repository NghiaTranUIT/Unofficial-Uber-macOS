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
    private let mask: NSEvent.EventTypeMask
    private let handler: EventMonitorHandler
    private var isMonitoring = false
    fileprivate let lock = NSLock()

    public init(mask: NSEvent.EventTypeMask, handler: @escaping EventMonitorHandler) {
        self.mask = mask
        self.handler = handler
    }

    deinit {
        stop()
    }

    public func start() {

        // Lock
        lock.lock()
        defer {
            self.lock.unlock()
        }

        guard isMonitoring == false else { return }
        monitor = NSEvent.addGlobalMonitorForEvents(matching: self.mask, handler: self.handler)
        isMonitoring = true
    }

    public func stop() {

        // Lock
        lock.lock()
        defer {
            self.lock.unlock()
        }

        guard isMonitoring else { return }

        if self.monitor != nil {
            NSEvent.removeMonitor(self.monitor!)
            self.monitor = nil
        }

        isMonitoring = false
    }
}
