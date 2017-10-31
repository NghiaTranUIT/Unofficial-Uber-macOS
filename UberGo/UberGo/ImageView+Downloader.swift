//
//  ImageView+Downloader.swift
//  UberGo
//
//  Created by Nghia Tran on 9/17/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa

extension NSImageView {

    public func asyncDownloadImage(_ path: String) {

        // Reset
        self.image = nil

        // Avatar
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
            .async { [weak self] in
                guard let url = URL(string: path) else { return }
                let image = NSImage(contentsOf: url)
                DispatchQueue.main.async { [weak self] in
                    self?.image = image
                }
            }
    }
}
