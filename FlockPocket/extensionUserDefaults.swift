//
//  extensionUserDefaults.swift
//  FlockPocket
//
//  Created by snow on 2/21/24.
//

import Foundation

extension UserDefaults {
 
    var developerMode: Bool {
        get { return bool(forKey: #function) }
        set { set(newValue, forKey: #function) }
    }
    var ownUserId: String? {
        get { return string(forKey: #function) }
        set { set(newValue, forKey: #function) }
    }
    var password: String? {
        get { return string(forKey: #function) }
        set { set(newValue, forKey: #function) }
    }
    var server: String? {
        get { return string(forKey: #function) }
        set { set(newValue, forKey: #function) }
    }
    var websocketFailureCounter: Int? {
        get { return integer(forKey: #function) }
        set { set(newValue, forKey: #function) }
    }
    var username: String? {
        get { return string(forKey: #function) }
        set { set(newValue, forKey: #function) }
    }
    var usernameAndPasswordSaved: Bool {
        get { return bool(forKey: #function) }
        set { set(newValue, forKey: #function) }
    }
}
