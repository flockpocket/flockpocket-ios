//
//  ChatInlineTimestamps.swift
//  FlockPocket
//
//  Created by snow on 1/12/24.
//

import SwiftUI

struct ChatInlineTimestamps: View {
    var relativeDate: String
    var formattedTime: String
    
    init(timestamp: Double) {
        let relativeFormatter = RelativeDateTimeFormatter()
        relativeFormatter.unitsStyle = .full
        relativeFormatter.dateTimeStyle = .named
        self.relativeDate = relativeFormatter.localizedString(
            for: Date(timeIntervalSince1970: timestamp),
            relativeTo: Date.now
        )
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        self.formattedTime = dateFormatter.string(from: Date(timeIntervalSince1970: timestamp))
        
    }
    
    var body: some View {
        HStack {
            Text(relativeDate)
            Text(formattedTime)
        }
    }
}
