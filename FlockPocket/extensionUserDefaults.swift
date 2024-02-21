//
//  extensionUserDefaults.swift
//  FlockPocket
//
//  Created by snow on 2/21/24.
//

import Foundation

extension UserDefaults {
 
    var usernameAndPasswordSaved: Bool {
        get { return bool(forKey: #function) }
        set { set(newValue, forKey: #function) }
    }
    var password: String? {
        get { return string(forKey: #function) }
        set { set(newValue, forKey: #function) }
    }
    var username: String? {
        get { return string(forKey: #function) }
        set { set(newValue, forKey: #function) }
    }
    
    var developerMode: Bool {
        get { return bool(forKey: #function) }
        set { set(newValue, forKey: #function) }
    }
}
