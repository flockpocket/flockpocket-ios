//
//  NotificationService.swift
//  NotificationUUIDToName
//
//  Created by snow on 2/16/24.
//

import Foundation
import UserNotifications
import CoreData

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            let context = PersistenceController.shared!.container.viewContext
            let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id LIKE %@", bestAttemptContent.title)
            if let user = try! context.fetch(fetchRequest).first {
                bestAttemptContent.title = user.full_name!
            } else {
                bestAttemptContent.title = "New User"
            }
            
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
