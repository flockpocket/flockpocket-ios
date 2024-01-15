//
//  NotificationPermissionsView.swift
//  FlockPocket
//
//  Created by snow on 1/15/24.
//

import SwiftUI

struct NotificationPermissionsView: View {
    private let timer = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()
    
    @State var persistentBannerEnabled = false
    @State var bannerEnabled = false
    @State var soundEnabled = false
    @State var lockScreenEnabled = false
    @State var notificationsEnabled = false
    @State var timeSensitiveEnabled = false
    @State var criticalAlertsEnabled = false
    
    var body: some View {
        List {
            Section(header: Text("Permission to show notifications")) {
                PermissionListItemView(title: "Notifications", toggle: notificationsEnabled)
                PermissionListItemView(title: "Sound", toggle: soundEnabled)
            }
            
            Section(header: Text("Where to show notifications")) {
                PermissionListItemView(title: "Lock Screen", toggle: lockScreenEnabled)
                PermissionListItemView(title: "Banner", toggle: bannerEnabled)
                if bannerEnabled {
                    PermissionListItemView( title: "(Persistent Banner)", toggle: persistentBannerEnabled)
                }
            }
            Section(header: Text("Special Permissions")) {
                PermissionListItemView(title: "Time Sensitive", toggle: timeSensitiveEnabled)
                PermissionListItemView(title: "Critical Alerts", toggle: criticalAlertsEnabled)
            }
            
            Section(footer: Text("Don't forget to check any Focus modes you use to grant appropriate permissions")) {
                Button("Open Notification Settings") {
                    if let url = URL(string: UIApplication.openNotificationSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            }
        }
        .onReceive(timer) { _ in
            setStates()
        }
    }
    
    fileprivate func setStates() {
        UNUserNotificationCenter.current().getNotificationSettings  { settings in
            bannerEnabled = settings.alertSetting.rawValue == 2
            criticalAlertsEnabled = settings.criticalAlertSetting.rawValue == 2
            if bannerEnabled {
                persistentBannerEnabled = settings.alertStyle.rawValue == 2
            }
            soundEnabled = settings.soundSetting.rawValue == 2
            lockScreenEnabled = settings.lockScreenSetting.rawValue == 2
            notificationsEnabled = settings.authorizationStatus.rawValue == 2
            timeSensitiveEnabled = settings.timeSensitiveSetting.rawValue == 2
        }
    }
}

struct PermissionListItemView: View {
    var title: String
    var toggle: Bool
    var body: some View {
        HStack {
            Text("\(title):")
            Spacer()
            Text(toggle ? "Enabled" : "Disabled")
        }
    }
}
