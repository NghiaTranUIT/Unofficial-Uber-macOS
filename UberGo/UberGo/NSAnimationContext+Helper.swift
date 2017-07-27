//
//  NSAnimationContext+Helper.swift
//  UberGo
//
//  Created by Nghia Tran on 6/17/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa

//TODO: Get rid of NSAnimationContext
// Accroding to http://jwilling.com/blog/osx-animations/
// NSAnimationContext is repeatedly calling setFrame/setOpacity on main thread due to no layer-backed
//
// Should replace with CABasicAnimation from Quarzt
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
