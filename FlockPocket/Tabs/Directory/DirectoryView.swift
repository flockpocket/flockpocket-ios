//
//  DirectoryView.swift
//  FlockPocket
//
//  Created by snow on 1/13/24.
//

import SwiftUI
import CoreData

struct DirectoryView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \User.full_name, ascending: true)],
        animation: .default)
    private var users: FetchedResults<User>
    
    var body: some View {
        
        NavigationView {
            List {
                Section("Users") {
                    ForEach(users, id: \.self) { user in
                        HStack {
                            NavigationLink {
                                DirectoryMemberView(user: Binding<User>.constant(user))
                            } label: {
                                ProfilePhoto(user: user)
                                Text(user.full_name!)
                            }
                        }
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
