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
    @State private var loggedIn = UserDefaults.standard.usernameAndPasswordSaved
    
    @State private var inviteEmail = "flockuser@snowskeleton.net"
    
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
                        UserDefaults.standard.username = username
                        UserDefaults.standard.password = password
                        UserDefaults.standard.usernameAndPasswordSaved = true
                        WebSocket.shared.login()
                        dismiss()
                    }
                    // invites are broken right now. Need to fix the server
                    //                TextField("Invite by Email", text: $inviteEmail)
                    //                Button("Invite User") {WebSocket.shared.inviteUser(email: inviteEmail)}
                    
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
