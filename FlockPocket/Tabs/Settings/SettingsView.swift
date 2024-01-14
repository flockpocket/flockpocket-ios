//
//  SettingsView.swift
//  FlockPocket
//
//  Created by snow on 1/13/24.
//

import SwiftUI
import CoreData

struct SettingsView: View {
    @State private var loggedIn: Bool
    @State private var showLogoutConfirmation = false
    @State private var showLoginView = false
    
    init() {
        _loggedIn = State(initialValue: UserDefaults.standard.bool(forKey: "usernameAndPasswordSaved"))
    }
    var body: some View {
        NavigationView {
            List {
                NavigationLink {
                    ProfileView()
                } label: {
                    Text("Profile")
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
            loggedIn = UserDefaults.standard.bool(forKey: "usernameAndPasswordSaved")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    func logoutUser() {
        WebSocket.shared.disconnect()
        UserDefaults.standard.set("", forKey: "username")
        UserDefaults.standard.set("", forKey: "password")
        UserDefaults.standard.set(false, forKey: "usernameAndPasswordSaved")
        loggedIn = false
        
        let userFetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "User")
        let userDeleteRequest = NSBatchDeleteRequest(fetchRequest: userFetchRequest)
        
        do {
            let container = PersistenceController.shared.container
            try container.persistentStoreCoordinator.execute(userDeleteRequest, with: container.viewContext)
        } catch { /* TODO: handle the error */ }
    }
}
