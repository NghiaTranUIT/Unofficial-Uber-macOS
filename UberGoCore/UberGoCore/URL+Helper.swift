//
//  URL+Helper.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/23/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation

extension URL {

    var allQueryItems: [URLQueryItem] {
        get {
            let components = URLComponents(url: self, resolvingAgainstBaseURL: false)!
            let allQueryItems = components.queryItems!
            return allQueryItems as [URLQueryItem]
        }
    }

    func queryItemForKey(key: String) -> URLQueryItem? {
        let predicate = NSPredicate(format: "name=%@", key)
        return (allQueryItems as NSArray).filtered(using: predicate).first as? URLQueryItem
    }
}
