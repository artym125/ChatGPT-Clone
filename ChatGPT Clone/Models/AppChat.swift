//
//  AppChat.swift
//  ChatGPT Clone
//
//  Created by Ostap Artym on 28.08.2024.
//

import Foundation
import CoreData

struct AppChat: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String?
    let model: String
    let lastMessageSend: Date
    let owner: String
    var messages: [AppMessage] = []

    init(id: String, title: String, subtitle: String?, model: String, lastMessageSend: Date, owner: String, messages: [AppMessage] = []) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.model = model
        self.lastMessageSend = lastMessageSend
        self.owner = owner
        self.messages = messages
    }

    init(entity: ChatEntity) {
        self.id = entity.id ?? UUID().uuidString
        self.title = entity.title ?? ""
        self.subtitle = entity.subtitle
        self.model = entity.model ?? "gpt-4o-mini"
        self.lastMessageSend = entity.lastMessageSend ?? Date()
        self.owner = entity.owner ?? ""
        self.messages = entity.messages?.compactMap { ($0 as? MessageEntity).map(AppMessage.init) } ?? []
    }
}
