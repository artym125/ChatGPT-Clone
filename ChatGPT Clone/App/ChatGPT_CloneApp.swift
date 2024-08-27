//
//  ChatGPT_CloneApp.swift
//  ChatGPT Clone
//
//  Created by Ostap Artym on 27.08.2024.
//

import SwiftUI

@main
struct ChatGPT_CloneApp: App {
    @ObservedObject var appState: AppState = AppState()
    let persistenceController = CoreDataManager.shared

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $appState.navigationPath) {
                ChatListView()
                    .environmentObject(appState)
                    .environment(\.managedObjectContext, persistenceController.context)
            }
        }
    }
}
