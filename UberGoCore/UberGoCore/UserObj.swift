//
//  UserObj.swift
//  UberGoCore
//
//  Created by Nghia Tran on 6/2/17.
//  Copyright © 2017 Nghia Tran. All rights reserved.
//

import Cocoa
import ObjectMapper

final class UserObj: BaseObj {

    // MARK: - Current User
    fileprivate struct Static {
        static var instance: UserObj?
    }

    // MARK: - Variable
    public var name: String?
    public var authenticateState: AuthenticationState = AuthenticationState.unAuthenticated
    public static var currentUser: UserObj? {
        self.lock.lock()
        defer {
            self.lock.unlock()
        }

        // Critical resource
        if Static.instance != nil {
            return Static.instance
        }

        // Try to get from Disk
        if let userObj = self.getFromDisk() {
            Static.instance = userObj
        }

        return Static.instance
    }

    // MARK: - Private
    fileprivate var _currentUserInstance: UserObj?
    private static let lock = NSLock()

    // MARK: - Init
    override func mapping(map: Map) {
        super.mapping(map: map)

        self.name <- map[Constants.Object.User.Name]
    }

    // MARK: - Public

}

// MARK: - Private
extension UserObj {

    fileprivate class func getFromDisk() -> UserObj? {

        guard let data = UserDefaults.standard.data(forKey: "UserData") else { return nil }
        guard let userObj = NSKeyedUnarchiver.unarchiveObject(with: data) as? UserObj else { return nil }

        return userObj
    }
}
