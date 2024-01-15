//
//  LoginView.swift
//  FlockPocket
//
//  Created by snow on 1/13/24.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var server: String
    @State private var username = ""
    @State private var password = ""
    let loggedIn = UserDefaults.standard.bool(forKey: "usernameAndPasswordSaved")
    
    init() {
        let server = UserDefaults.standard.string(forKey: "server") ?? "flock.runty.link"
        _server = State(initialValue: server)
        
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text(loggedIn ? "Logging into a different account will log you out of previous ones" : "") ) {
                    TextField("Server", text: $server)
                    TextField("Username", text: $username)
                        .textContentType(.username)
                        .keyboardType(.emailAddress)
                    SecureField("Password", text: $password)
                        .textContentType(.password)
                    Button("Login") {
                        if loggedIn {
                            SettingsView().logoutUser()
                        }
                        UserDefaults.standard.set(username, forKey: "username")
                        UserDefaults.standard.set(password, forKey: "password")
                        UserDefaults.standard.set(true, forKey: "usernameAndPasswordSaved")
                        WebSocket.shared.login()
                        dismiss()
                    }
                    //                TextField("Invite by Email", text: $inviteEmail)
                    //                Button("Invite User") {WebSocket.shared.inviteUser(email: inviteEmail)}
                    
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
