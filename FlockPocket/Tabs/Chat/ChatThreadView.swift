//
//  ChatThreadView.swift
//  FlockPocket
//
//  Created by snow on 1/10/24.
//

import Combine
import SwiftUI


struct ChatThreadView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Binding var thread: ChatThread
    var messagesFR: FetchRequest<Message>
    var messages: FetchedResults<Message> { messagesFR.wrappedValue }
    @State var sendableMessage: String = ""
    
    init(thread: Binding<ChatThread>) {
        _thread = thread
        messagesFR = FetchRequest(
            sortDescriptors: [SortDescriptor(\.timestamp)],
            predicate: NSPredicate(format: "thread.id == %@", _thread.id! as CVarArg )
        )
    }
    var body: some View {
        ScrollViewReader { scrollView in
            VStack {
                VStack {
                    ProfilePhoto(user: thread.user!)
                    Text(thread.user!.first_name!)
                }
//                Button("Exterminate") {
//                    let context = PersistenceController.shared.container.viewContext
//                    for message in messages {
//                        context.delete(message)
//                    }
//                    try! context.save()
//                }
                MessagesScrollView(messages: messages)
                HStack {
                    TextField("Say something funny!", text: $sendableMessage
                              // newlines break the FP server, so taking this out for now
                              //           , axis: .vertical
                    )
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {  send() }
                    Button {
                        send()
                    } label: {
                        Image(systemName: "arrow.up")
                            .foregroundColor(.white)
                            .padding(5)
                            .background(.blue)
                            .clipShape(.circle)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
            }
            .onAppear {
                scrollToBottom(of: scrollView)
                WebSocket.shared.sendSeen(thread)
            }
            .onChange(of: messages.last, {
                withAnimation {
                    scrollToBottom(of: scrollView)
                }
            })
            .onReceive(keyboardPublisher) { _ in
                withAnimation {
                    scrollToBottom(of: scrollView)
                }
            }
        }
    }
    
    fileprivate func scrollToBottom(of scrollView: ScrollViewProxy) {
        scrollView.scrollTo(messages.last, anchor: .bottom)
    }
    
    fileprivate func send() {
        if sendableMessage != "" {
            WebSocket.shared.sendChatMessage(to: thread.id!, saying: sendableMessage)
            sendableMessage = ""
        }
    }
}

private extension View {
    var keyboardPublisher: AnyPublisher<Bool, Never> {
        Publishers
            .Merge(
                NotificationCenter
                    .default
                    .publisher(for: UIResponder.keyboardWillShowNotification)
                    .map { _ in true },
                NotificationCenter
                    .default
                    .publisher(for: UIResponder.keyboardWillHideNotification)
                    .map { _ in false })
            .debounce(for: .seconds(0.1), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
}

struct MessagesScrollView: View {
    @Environment(\.colorScheme) var colorScheme
    var messages: FetchedResults<Message>
    let ownId = UserDefaults.standard.value(forKey: "ownUserId") as! String
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(Array(messages.enumerated()), id: \.1.id) { (index, message) in
                    let previousMessage = (index == 0 ? nil : self.messages[index - 1])
                    
                    let own = message.user!.id! == ownId
                    let previousOwn = previousMessage?.user!.id! == ownId
                    let sameOwnerForBothMessages = own == previousOwn
                    
                    if message.timestamp - (previousMessage?.timestamp ?? 0) > 3600 {
                        ChatInlineTimestamps(timestamp: message.timestamp)
                    }
                    ChatMessageBubble(
                        message: message,
                        previousMessage: previousMessage,
                        wing: message.timestamp - (previousMessage?.timestamp ?? 0) < 60 && sameOwnerForBothMessages
                    )
                    .id(message)
                    .padding(.top, message.timestamp - (previousMessage?.timestamp ?? 0) < 60 && sameOwnerForBothMessages ? -7 : 5)
                    .foregroundColor(colorScheme == .light && !own ? .black : .white )
                    .padding(.horizontal, 15)
                    
                }
            }
        }
    }
}
