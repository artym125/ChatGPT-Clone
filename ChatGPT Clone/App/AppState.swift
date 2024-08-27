//
//  AppState.swift
//  ChatGPT Clone
//
//  Created by Ostap Artym on 28.08.2024.
//

import SwiftUI

@MainActor
class AppState: ObservableObject {
    @Published var navigationPath = NavigationPath()
}
