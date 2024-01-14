//
//  extensionChatThread.swift
//  FlockPocket
//
//  Created by snow on 1/13/24.
//

import Foundation

extension ChatThread {
    var length: Int64 {
        if let count = self.messages?.count {
            return Int64(count)
        } else {
            return 0
        }
    }
}
