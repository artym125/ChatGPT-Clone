//
//  ChatGPT_CloneApp.swift
//  ChatGPT Clone
//
//  Created by Ostap Artym on 27.08.2024.
//

import SwiftUI

@main
struct ChatGPT_CloneApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
