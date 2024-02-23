//
//  extensionUNNotificationResponse.swift
//  FlockPocket
//
//  Created by snow on 2/23/24.
//

import Foundation
import SwiftUI

extension UNNotificationResponse {
    var id: String {
        let uinfo = self.notification.request.content.userInfo
        let id = (uinfo["aps"]! as! [String: Any])["thread-id"]! as! String
        return id
    }
}
