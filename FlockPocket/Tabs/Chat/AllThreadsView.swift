//
//  AllThreadsView.swift
//  FlockPocket
//
//  Created by snow on 1/13/24.
//

import SwiftUI
import CoreData

struct AllThreadsView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ChatThread.timestamp, ascending: true)],
        animation: .default)
    private var threads: FetchedResults<ChatThread>
    
    var body: some View {
        NavigationView {
            List {
                Section("Chat Threads") {
                    ForEach(threads, id: \.self) { thread in
                        NavigationLink {
                            ChatThreadView(thread: Binding<ChatThread>.constant(thread))
                        } label: {
                            if let user = thread.user {
                                ProfilePhoto(user: user)
                                Text(user.full_name!)
                            } else {
                                ProgressView()
                            }
                        }
                    }
                }
            }
        }
        .badge(unreadThreads(threads))
        .navigationViewStyle(StackNavigationViewStyle())
    }
    private func unreadThreads(_ threads: FetchedResults<ChatThread>) -> Int {
        return 2
    }
}
