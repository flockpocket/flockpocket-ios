//
//  NotificationViewModifier.swift
//  FlockPocket
//
//  Created by snow on 1/21/24.
//

import SwiftUI

struct NotificationViewModifier: ViewModifier {
    // MARK: - Private Properties
    private let onNotification: (UNNotificationResponse) -> Void
    
    // MARK: - Initializers
    init(onNotification: @escaping (UNNotificationResponse) -> Void, handler: NotificationHandler) {
        self.onNotification = onNotification
    }
    
    // MARK: - Body
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationHandler.shared.$latestNotification) { notification in
                guard let notification else { return }
                onNotification(notification)
            }
    }
}
