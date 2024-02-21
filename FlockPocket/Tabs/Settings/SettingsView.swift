//
//  SettingsView.swift
//  FlockPocket
//
//  Created by snow on 1/13/24.
//

import SwiftUI
import CoreData

struct SettingsView: View {
    @State private var showLogoutConfirmation = false
    @State private var showLoginView = false
    
    @State private var enableDeveloperMode = UserDefaults.standard.developerMode
    @State private var loggedIn = UserDefaults.standard.usernameAndPasswordSaved
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink {
                    ProfileView()
                } label: {
                    Text("Profile")
                }
                NavigationLink {
                    NotificationPermissionsView()
                } label: {
                    Text("Notification Permissions")
                }
                Section("Login") {
                    Button("Login") {
                        showLoginView = true
                    }
                    if loggedIn {
                        Button(role: .destructive ) {
                            showLogoutConfirmation = true
                        } label: {
                            Text("Logout")
                        }
                    }
                }
                Section("Developer") {
                    Toggle("Developer Mode", isOn: $enableDeveloperMode)
                        .onChange(of: enableDeveloperMode) {
                            UserDefaults.standard.developerMode = enableDeveloperMode
                        }
                }
            }
        }
        .confirmationDialog("Are you sure?", isPresented: $showLogoutConfirmation) {
            Button("Logout", role: .destructive) {
                logoutUser()
            }
        }
        .sheet(isPresented: $showLoginView) {
            LoginView()
        }
        .onChange(of: showLoginView) {
            loggedIn = UserDefaults.standard.usernameAndPasswordSaved
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    func logoutUser() {
        WebSocket.shared.disconnect()
        UserDefaults.standard.username = ""
        UserDefaults.standard.password = ""
        UserDefaults.standard.usernameAndPasswordSaved = false
        loggedIn = false
        
        let userFetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "User")
        let userDeleteRequest = NSBatchDeleteRequest(fetchRequest: userFetchRequest)
        
        do {
            let container = PersistenceController.shared!.container
            try container.persistentStoreCoordinator.execute(userDeleteRequest, with: container.viewContext)
        } catch { /* TODO: handle the error */ }
    }
}
