//
//  View+Notifications.swift
//  FlockPocket
//
//  Created by snow on 1/21/24.
//

import SwiftUI

extension View {
    func onNotification(perform action: @escaping (UNNotificationResponse) -> Void) -> some View {
        modifier(NotificationViewModifier(onNotification: action, handler: NotificationHandler.shared))
    }
}
