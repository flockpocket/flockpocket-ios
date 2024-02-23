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
    
    @State private var loggedIn = UserDefaults.standard.usernameAndPasswordSaved
    @State private var showLoginView: Bool = false
    
    @State private var inviteEmail = "isaac+something@snowskeleton.net"
    @State private var launchedWithNotification = false
    @State private var chatThreadToLaunch: String = ""
    
    var body: some View {
        NavigationStack {
            TabView {
                AllThreadsView()
                    .tabItem {
                        Label("Messages", systemImage: "message")
                    }
                    .navigationDestination(isPresented: $launchedWithNotification) {
                        if launchedWithNotification {
                            ChatThreadView(threadId: chatThreadToLaunch)
                        }
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
        }
        .onLaunchWithNotification { notification in
            print("Launched with notification")
            let uinfo = notification.notification.request.content.userInfo
            let id = (uinfo["aps"]! as! [String: Any])["thread-id"]! as! String
            chatThreadToLaunch = id
            launchedWithNotification = true
        }
        .onForegroundNotification { notification in
            print("Notification while in foreground")
            print(notification.request.content.userInfo)
        }
        .onAppear() {
            if !loggedIn {
                showLoginView = true
            } else {
                WebSocket.shared.login()
            }
        }
        .onDisappear() {
            WebSocket.shared.disconnect()
        }
        .sheet(isPresented: $showLoginView) {
            LoginView()
        }
    }
}
