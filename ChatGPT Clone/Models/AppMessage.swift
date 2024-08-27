//
//  AppMessage.swift
//  ChatGPT Clone
//
//  Created by Ostap Artym on 28.08.2024.
//

import Foundation
import OpenAI
import CoreData

struct AppMessage: Identifiable, Codable, Hashable {
    let id: String
    var text: String
    let role: Chat.Role
    let createdAt: Date

    init(entity: MessageEntity) {
        self.id = entity.id ?? UUID().uuidString
        self.text = entity.text ?? ""
        self.role = Chat.Role(rawValue: entity.role ?? "") ?? .user
        self.createdAt = entity.createdAt ?? Date()
    }
    
    init(id: String, text: String, role: Chat.Role, createdAt: Date) {
        self.id = id
        self.text = text
        self.role = role
        self.createdAt = createdAt
    }
}
