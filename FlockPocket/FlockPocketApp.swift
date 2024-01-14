//
//  FlockPocketApp.swift
//  FlockPocket
//
//  Created by snow on 12/5/23.
//

import SwiftUI
import CoreData

@main
struct FlockPocketApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
