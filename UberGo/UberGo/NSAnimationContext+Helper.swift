//
//  NSAnimationContext+Helper.swift
//  UberGo
//
//  Created by Nghia Tran on 6/17/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa

extension NSAnimationContext {

    class func defaultAnimate(_ block: (NSAnimationContext) -> Void, completion: (() -> Void)? = nil) {
        NSAnimationContext.runAnimationGroup({ context in

            // Default
            context.allowsImplicitAnimation = true
            context.duration = 0.22
            context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)

            // Run
            block(context)
        }, completionHandler: completion)
    }
}
