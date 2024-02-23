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
    var latestMessage: Message? {
        return self.messages?.sortedArray(using: [NSSortDescriptor(key: "timestamp", ascending: false)]).first as? Message ?? nil
    }
}

