//
//  AppDelegate.swift
//  FlockPocket
//
//  Created by snow on 1/15/24.
//

import SwiftUI
import Foundation
import UserNotifications

class AppState: ObservableObject {
    static let shared = AppState()
    @Published var pageToNavigationTo : String?
    @Published var thread : ChatThread?
}

class AppDelegate: NSObject, UIApplicationDelegate {
    // Handle receiving notifications
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        registerForPushNotifications()
//        let notificationOption = launchOptions?[.remoteNotification]
//        
//        // 1
//        if
//            let notification = notificationOption as? [String: AnyObject],
//            let aps = notification["aps"] as? [String: AnyObject] {
//            // 2
////            NewsItem.makeNewsItem(aps)
//            
//            // 3
////            (window?.rootViewController as? UITabBarController)?.selectedIndex = 1
//        }
        return true
    }
    
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler:
        @escaping (UIBackgroundFetchResult) -> Void
    ) {
        guard let aps = userInfo["aps"] as? [String: AnyObject] else {
            completionHandler(.failed)
            return
        }
        WebSocket.shared.login()
        WebSocket.shared.disconnect()
    }

    
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        WebSocket.shared.registerForPushNotifications(with: token)
//        print("Device Token: \(token)")
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Failed to register for notifications: \(error.localizedDescription)")
    }

    func registerForPushNotifications() {
        UNUserNotificationCenter.current()
            .requestAuthorization(
                options: [.alert, .sound, .badge]) { [weak self] granted, _ in
                    print("Permission granted: \(granted)")
                    guard granted else { return }
                    // set categories, to do actions from the notification directly
//                    // 1
//                    let viewAction = UNNotificationAction(
//                        identifier: Identifiers.viewAction,
//                        title: "View",
//                        options: [.foreground])
//                    
//                    // 2
//                    let newsCategory = UNNotificationCategory(
//                        identifier: Identifiers.newsCategory,
//                        actions: [viewAction],
//                        intentIdentifiers: [],
//                        options: [])
//                    
//                    // 3
//                    UNUserNotificationCenter.current().setNotificationCategories([newsCategory])
//                    
                    self?.getNotificationSettings()
                }
        
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
//            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        print(response)
        // Handle receiving of notification
    }
    
    // Needed if notifications should be presented while the app is in the foreground
    func userNotificationCenter(
        _: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.list, .banner, .sound])
    }
    
}
