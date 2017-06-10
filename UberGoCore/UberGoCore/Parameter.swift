//
//  Parameters.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/6/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation

// MARK: - Generic param
protocol Parameter {

    // Convert to dictionary
    // work seamless with Alamofire
    func toDictionary() -> [String: Any]
}
