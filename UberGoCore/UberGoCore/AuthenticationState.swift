//
//  AuthenticationState.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/2/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Foundation

// MARK: - Authentication State
public enum AuthenticationState {

    // Authenticated successfully and valid token from Uber
    case authenticated

    // Otherwise case
    case unAuthenticated
}
