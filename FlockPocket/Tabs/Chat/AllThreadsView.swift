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
                            ThreadPreview(thread: thread)
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

struct ThreadPreview: View {
    @ObservedObject var thread: ChatThread
    @AppStorage("developerMode") var developerMode = false
    
    var body: some View {
        if let user = thread.user {
            VStack {
                HStack {
                    ProfilePhoto(user: user)
                    VStack {
                        HStack {
                            Text(user.full_name!)
                            if developerMode {
                                Text(user.id!)
                            } else {
                                Spacer()
                            }
                        }.font(.headline)
                        HStack {
                            Text("\(thread.latestMessage?.user?.first_name ?? ""): ")
                            Text(thread.latestMessage?.text ?? "")
                            Spacer()
                        }.font(.subheadline.weight(.light))
                        
                    }
                }
            }
        } else {
            ProgressView()
        }
    }
}

extension ChatThread {
    var latestMessage: Message? {
        return self.messages?.sortedArray(using: [NSSortDescriptor(key: "timestamp", ascending: false)]).first as? Message ?? nil
    }
}
