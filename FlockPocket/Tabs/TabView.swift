//
//  ContentView.swift
//  FlockPocket
//
//  Created by snow on 12/5/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    let loggedIn = UserDefaults.standard.bool(forKey: "usernameAndPasswordSaved")
    @State private var showLoginView: Bool = false
    
    @State private var inviteEmail = "isaac+something@snowskeleton.net"
    
    var body: some View {
        TabView {
            AllThreadsView()
                .tabItem {
                    Label("Messages", systemImage: "message")
                }
            DirectoryView()
                .tabItem {
                    Label("Directory", systemImage: "person.3.sequence")
                }
            SettingsView()
                .badge("!")
                .tabItem {
                    Label("Account", systemImage: "gear")
                }
        }
        .onAppear() {
            notificationRegistration()
            if loggedIn {
                WebSocket.shared.login()
            } else {
                showLoginView = true
            }
        }
        .onDisappear() {
            WebSocket.shared.disconnect()
        }
        .sheet(isPresented: $showLoginView) {
            LoginView()
        }
    }
    fileprivate func notificationRegistration() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("D'oh: \(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
}
