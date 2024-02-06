//
//  WebSockets.swift
//  FlockPocket
//
//  Created by snow on 1/10/24.
//

import Foundation
import CoreData
import SwiftUI
//let hostUrl = "localhost"
var hostUrl: String {
    UserDefaults.standard.string(forKey: "server") ?? "flock.runty.link"
}
class WebSocket {
    
    static let shared = WebSocket()
    
    var wsTask: URLSessionWebSocketTask?
    var session = URLSession(configuration: .default)
    var isConnected: Bool = false
    
    private var printResponse = true
    
    func inviteUser(email: String) {
        Task {
            let (data, _) = try await session.data(from: URL(string: "https://\(hostUrl)")!)
            if printResponse {
                print(String(data: data, encoding: .utf8)!)
            }
//            let csrfToken = extractCSRFToken(from: data)!
            // build request
            var urlComponents = URLComponents()
            urlComponents.scheme = "https"
            urlComponents.host = hostUrl
            urlComponents.path = "/api/invite_user/"
            let newUserEmail = URLQueryItem(name: "email", value: email)
//            let qiCsrfToken = URLQueryItem(name: "csrfmiddlewaretoken", value: "\(csrfToken)")
            urlComponents.queryItems = [newUserEmail]
            if (urlComponents.percentEncodedQuery == nil) { return }
            var request = URLRequest(url: URL(string: "https://\(hostUrl)/api/invite_user/")!)
//            var request = URLRequest(url: urlComponents.url!)
            request.httpMethod = "POST"
            request.httpBody = urlComponents.percentEncodedQuery!.data(using: .utf8)
            // send new user request
            let (someData, _) = try await session.data(for: request)
            if printResponse {
                print(String(data: someData, encoding: .utf8)!)
            }
        }
    }
    
    /**
     Login with saved values from UserDefaults.
     Set keys "username" and "password" appropriately
     */
    func login() {
        Task {
            // get CSRF token for loggin in
            let store = HTTPCookieStorage.shared
            for cookie in store.cookies ?? [] {
                store.deleteCookie(cookie)
            }
            let (data, _) = try await session.data(from: URL(string: "https://\(hostUrl)")!)
//            print(String(data: data, encoding: .utf8)!)
            guard let csrfToken = extractCSRFToken(from: data) else { return }
            
            // build request
            var urlComponents = URLComponents()
            urlComponents.scheme = "https"
            urlComponents.host = hostUrl
            urlComponents.path = "/login/"
            let username = UserDefaults.standard.string(forKey: "username")!
            let password = UserDefaults.standard.string(forKey: "password")!
            let qiUsername = URLQueryItem(name: "username", value: username)
            let qiPassword = URLQueryItem(name: "password", value: password)
            let qiCsrfToken = URLQueryItem(name: "csrfmiddlewaretoken", value: "\(csrfToken)")
            urlComponents.queryItems = [qiPassword, qiUsername, qiCsrfToken]
            if (urlComponents.percentEncodedQuery == nil) { return }
            var request = URLRequest(url: urlComponents.url!)
            request.httpMethod = "POST"
            request.httpBody = urlComponents.percentEncodedQuery!.data(using: .utf8)
            // send login request
            let (loginData, _) = try await session.data(for: request)
            if String(data: loginData, encoding: .utf8)!.contains("Invalid") {
                print("Error logging in. Retry with a different username or password")
                return
            } else {
                self.isConnected = true
            }
            
            // upgrade to websocket
            var wsUrlComps = URLComponents()
            wsUrlComps.scheme = "wss"
            wsUrlComps.host = hostUrl
            wsUrlComps.path = "/ws/api/"
            var wsRequest = URLRequest(url: wsUrlComps.url!)
            wsRequest.httpMethod = "GET"
            let wsTask = session.webSocketTask(with: wsRequest)
            // persist websocket
            self.wsTask = wsTask
            self.wsTask!.resume()
            self.pingPong()
            self.receive()
            WebSocket.shared.send(string: #""ui_config""#)
            
            // I'd like for this to happen separately in an .onAppear {} block,
            //but can't figure out how to sequence it such that it only happens after finishing the login process
            NotificationHandler.shared.getNotificationSettings()
        }
    }
    
     func send(string: String) {
         Task {
             if let task = self.wsTask {
                 task.send(URLSessionWebSocketTask.Message.string(string)) { error in
                     if let error = error {
                         print("Send error: \(error)")
                     }
                 }
             } else {
                 print("Tried to send with nonexistent websocket task")
             }
         }
     }
    
    private func recoverConnection() {
        print("Connection failed")
        var failureCount = UserDefaults.standard.integer(forKey: "websocketFailureCounter")
        failureCount += 1
        UserDefaults.standard.setValue(failureCount, forKey: "websocketFailureCounter")
        if failureCount < 8 {
            let retryDelay = Int(pow(2.0, Double(failureCount - 1)))
            print("Retrying connection \(failureCount)/7 times after \(retryDelay)")
            DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(retryDelay)) {
                self.login()
            }
        }
    }
    
    func disconnect() {
        if let task = self.wsTask {
            self.isConnected = false
            task.cancel(with: .goingAway, reason: nil)
        } else {
            print("Tried to disconnect from nonexistent task")
        }
    }
    
    private func pingPong() {
        if let task = self.wsTask {
            task.sendPing { error in
                if let error = error {
                    print("Failed ping-pong: \(error)")
                    self.isConnected = false
                } else {
                    self.isConnected = true
                    DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
                        self.pingPong()
                    }
                }
            }
        } else {
            print("Can't play ping-ping with nonexistent websocket task")
        }
    }
    
    private func receive() {
        Task {
            if let task = self.wsTask {
                task.receive { result in
                    switch result {
                    case .failure(let error):
                        print("Received error from websocket server: \(error)")
                        return self.recoverConnection()
                    case .success(let message):
                        switch message {
                        case .string(let text):
                            let data = text.data(using: .utf8)!
                            let decoded = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                            if self.printResponse { print(decoded!) }
                            if decoded!.keys.contains("ui_config") {
                                updateUsers(with: decoded!)
                                updateAllThreads(with: decoded!)
                            }
                            if decoded!.keys.contains("thread") {
                                updateThread(with: decoded!["thread"] as! [String: Any])
                            }
                            if decoded!.keys.contains("message") {
                                updateMessage(with: decoded!)
                            }
                            if decoded!.keys.contains("user") {
                                updateSingleUser(with: decoded!["user"] as! [String: Any])
                            }
                            if decoded!.keys.contains("typing") {
                                updateLocalTyping(with: decoded!["typing"] as! [String: Any])
                            }
                        case .data(let data):
                            print("Received binary message: \(data)")
                        @unknown default:
                            fatalError()
                        }
                    }
                    UserDefaults.standard.setValue(0, forKey: "websocketFailureCounter")
                    self.receive()
                }
            } else {
                print("Can't receive from nonexistent websocket task")
            }
        }
    }
    
    // Extract CSRF token from HTML response
    private func extractCSRFToken(from data: Data) -> String? {
        guard let htmlString = String(data: data, encoding: .utf8) else { return nil }
        
        // Define the regular expression pattern
        let pattern = #"name="csrfmiddlewaretoken" value="([^"]+)""#
        
        // Try to find the range of the pattern in the HTML string
        guard let csrfTokenRange = htmlString.range(of: pattern, options: .regularExpression) else {
            return nil
        }
        
        // Check if the range is within the bounds of the string
        guard csrfTokenRange.upperBound <= htmlString.endIndex else {
            return nil
        }
        
        // Extract the CSRF token from the matched substring
        let csrfToken = String(htmlString[csrfTokenRange])
        
        // Extract the CSRF token value from the matched substring
        let csrfTokenValue = csrfToken.replacingOccurrences(of: pattern, with: "$1", options: .regularExpression)
        //            print(csrfTokenValue)
        return csrfTokenValue
    }
    
    public func requestThreadUpdate(with threadId: String) {
        self.send(string: #"{"chat.get_thread_history": {"thread_id": "\#(threadId)"}}"#)
    }
    
    public func sendChatMessage(to thread: String, saying text: String) {
        let ownId = UserDefaults.standard.object(forKey: "ownUserId") as! String
        self.send(string: #"{"chat.send_message": {"thread_id": "\#(thread)", "user_id": "\#(ownId)", "text": "\#(text)"}}"#)
    }
    
    public func sendSeen(_ thread: ChatThread) {
        self.send(string: #"{"chat.send_seen": {"thread_id": "\#(thread.id!)", "message_idx": \#(thread.length)}}"#)
    }
    
    func sendTypingStatus(for thread: ChatThread, with status: Bool) {
        var command: String
        if status == true {
            command = #"{"chat.send_typing": {"thread_id": "\#(thread.id!)"}}"#
        } else {
            command = #"{"chat.send_typing": {"clear": true, "thread_id": "\#(thread.id!)"}}"#
        }
        self.send(string: command)
    }
    
    public func registerForPushNotifications(with token: String) {
        guard let deviceId = UIDevice().identifierForVendor else { return }
        let command = #"{"register_for_push_notifications_ios": {"token": "\#(token)", "deviceId": "\#(deviceId)"}}"#
        self.send(string: command)
    }
}


func updateLocalTyping(with data: [String: Any]) {
    let context = PersistenceController.shared.container.viewContext
    
    let remoteTyping = data
    let typingThreadId = remoteTyping["thread"] as! String
    let typingFetchRequest: NSFetchRequest<TypingIndicator> = TypingIndicator.fetchRequest()
    typingFetchRequest.predicate = NSPredicate(format: "thread.id LIKE %@", typingThreadId)
    let typing = try! context.fetch(typingFetchRequest).first ?? TypingIndicator(context: context)
    
    let threadFetchRequest: NSFetchRequest<ChatThread> = ChatThread.fetchRequest()
    threadFetchRequest.predicate = NSPredicate(format: "id LIKE %@", typingThreadId)
    let thread = try! context.fetch(threadFetchRequest).first ?? ChatThread(context: context)
    
    let userId = remoteTyping["user"] as! String
    let userFetchRequest: NSFetchRequest<User> = User.fetchRequest()
    userFetchRequest.predicate = NSPredicate(format: "id LIKE %@", userId)
    let user = try! context.fetch(userFetchRequest).first ?? User(context: context)
    
    if typing.id == nil {
        typing.id = UUID()
    }
    typing.thread = thread
    typing.user = user
    typing.active = remoteTyping["clear"] as! Int == 0 ? true : false
    try! context.save()
}

func updateMessage(with data: [String: Any]) {
    let context = PersistenceController.shared.container.viewContext
    
    let newMessage = data["message"] as! [String: Any]
    let threadId = newMessage["thread"]
    let chatThreadFetchRequest: NSFetchRequest<ChatThread> = ChatThread.fetchRequest()
    chatThreadFetchRequest.predicate = NSPredicate(format: "id LIKE %@", threadId as! String)
    // what happens if we get a chat request with no assocciated thread?
    let chatThread = try! context.fetch(chatThreadFetchRequest).first ?? ChatThread(context: context)
    
    let remoteMessage = newMessage["message"] as! [String: Any]
    
    createLocalMessageFromRemote(from: remoteMessage, for: chatThread)
}

func updateThread(with data: [String: Any]) {
    let context = PersistenceController.shared.container.viewContext
    let threadId = data["id"]
    let fetchRequest: NSFetchRequest<ChatThread> = ChatThread.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "id LIKE %@", threadId as! String)
    let chatThread = try! context.fetch(fetchRequest).first ?? ChatThread(context: context)
    if let id = data["id"] {
        chatThread.id = (id as! String)
    }
    if let label = data["label"] {
        chatThread.label = (label as! String)
    }
    if let timestamp = data["timestamp"] {
        chatThread.timestamp = "\(timestamp)"
    }
    if let type = data["type"] {
        chatThread.type = (type as! Int64)
    }
//    if let seenList = data["seen"] {
////        let fetchRequest: NSFetchRequest<ChatThread> = ChatThread.fetchRequest()
////        fetchRequest.predicate = NSPredicate(format: "id LIKE %@", threadId as! String)
////        let chatThread = try! context.fetch(fetchRequest).first ?? ChatThread(context: context)
////        for (key, value) in seenList as! [String: Any] {
////            print(seenList)
////        }
//    }
    // NOT own user
    if let userId = data["user"] {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id LIKE %@", userId as! String)
        let user = try! context.fetch(fetchRequest).first ?? User(context: context)
        chatThread.user = user
    }
    
    do {
        try context.save()
    } catch let error {
        print("Error in saving thread: \(error)")
        return
    }
    
    if let messages = data["message_l"] {
        for remoteMessage in messages as! [[String: Any]] {
            createLocalMessageFromRemote(from: remoteMessage, for: chatThread)
        }
    }
}

func createLocalMessageFromRemote(from messageData: [String: Any], for thread: ChatThread) {
    let context = PersistenceController.shared.container.viewContext
    
    let timestamp = messageData["timestamp"] as! Double
    let messageFetchRequest: NSFetchRequest<Message> = Message.fetchRequest()
    messageFetchRequest.predicate = NSPredicate(format: "timestampAsString LIKE %@", "\(timestamp)")
    let message = try! context.fetch(messageFetchRequest).first ?? Message(context: context)
    
    let userId = (messageData["user"] as! String)
    let userFetchRequest: NSFetchRequest<User> = User.fetchRequest()
    userFetchRequest.predicate = NSPredicate(format: "id LIKE %@", userId)
    let user = try! context.fetch(userFetchRequest).first!
    
    message.text = (messageData["text"] as! String)
    message.timestamp = timestamp
    // the above messageFetchRequest likes to do weird things if it has to search with a key of a Double,
    // so we're saving the timestamp as a string so we can search it later without random crashes
    message.timestampAsString = "\(timestamp)"
    message.thread = thread
    message.user = user
    
    try? context.save()
}

func updateSingleUser(with data: [String: Any]) {
    let context = PersistenceController.shared.container.viewContext
    
    let remoteUser = data
    let id = remoteUser["id"]
    let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "id LIKE %@", id as! String)
    let user = try! context.fetch(fetchRequest).first ?? User(context: context)
    
    if let first_name = remoteUser["first_name"] {
        user.first_name = (first_name as! String)
    }
    if let last_name = remoteUser["last_name"] {
        user.last_name = (last_name as! String)
    }
    if let phone = remoteUser["phone"] {
        user.phone = (phone as! String)
    }
    if let email = remoteUser["email"] {
        user.email = (email as! String)
    }
    if let id = remoteUser["id"] {
        user.id = (id as! String)
    }
    if let full_name = remoteUser["full_name"] {
        user.full_name = (full_name as! String)
    }
    if let active = remoteUser["active"] {
        user.active = (active as! Int == 1 ? true : false )
    }
    if let gender = remoteUser["gender"] {
        user.gender = (gender as! String)
    }
    if let address = remoteUser["address"] {
        user.address = (address as! String)
    }
    if let birthday = remoteUser["birthday"] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let dateBirthday = dateFormatter.date(from: (birthday as! String))
        
        user.birthday = dateBirthday
        user.birthdayString = birthday as? String
    }
    if let pic = remoteUser["pic"] {
        user.pic = (pic as! String)
    }
    if let membership_status = remoteUser["membership_status"] {
        user.membership_status = (membership_status as! String)
    }
    
    try? context.save()
}

func updateUsers(with data: [String: Any]) {
    let ui_config = data["ui_config"]! as! [String: Any]
    if let ownID = ui_config["user_id"] {
        UserDefaults.standard.set(ownID, forKey: "ownUserId")
    }
    let users = ui_config["user_d"]! as! [String: Any]
    for (_, value) in users {
        updateSingleUser(with: value as! [String: Any])
    }
}

func updateAllThreads(with data: [String: Any]) {
    let ui_config = data["ui_config"]! as! [String: Any]
    let threads = ui_config["thread_d"]! as! [String: Any]
    for (_, value) in threads {
        let remoteThread = value as! [String: Any]
        updateThread(with: remoteThread)
        WebSocket.shared.requestThreadUpdate(with: remoteThread["id"] as! String)
    }
}
