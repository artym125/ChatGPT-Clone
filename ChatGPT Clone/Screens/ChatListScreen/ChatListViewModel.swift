//
//  ChatListViewModel.swift
//  ChatGPT Clone
//
//  Created by Ostap Artym on 28.08.2024.
//

import SwiftUI
import CoreData

class ChatListViewModel: ObservableObject {
    @Published var chats: [AppChat] = []
    @Published var loadingState: ChatListState = .none
    
    private var coreDataManager = CoreDataManager.shared
    
    init() {
        fetchData()
    }
    
    func fetchData() {
        let fetchRequest: NSFetchRequest<ChatEntity> = ChatEntity.fetchRequest()
        
        do {
            let chatEntities = try coreDataManager.context.fetch(fetchRequest)
            self.chats = chatEntities.map { AppChat(entity: $0) }
            self.loadingState = .resultFound
        } catch {
            print("Failed to fetch chats: \(error)")
            self.loadingState = .noResult
        }
    }
    
    func createChat(chat: AppChat) {
        let newChat = ChatEntity(context: coreDataManager.context)
        newChat.id = chat.id
        newChat.title = chat.title
        newChat.subtitle = chat.subtitle
        newChat.model = chat.model
        newChat.lastMessageSend = chat.lastMessageSend
        newChat.owner = chat.owner
        
        // Create messages for the chat
        for message in chat.messages {
            let newMessage = MessageEntity(context: coreDataManager.context)
            newMessage.id = message.id
            newMessage.text = message.text
            newMessage.role = message.role.rawValue
            newMessage.createdAt = message.createdAt
            newMessage.chat = newChat  // Set relationship
        }
        
        coreDataManager.saveContext()
        fetchData()
    }
    
    func deleteChat(chat: AppChat) {
        let fetchRequest: NSFetchRequest<ChatEntity> = ChatEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", chat.id)
        
        do {
            let chatEntities = try coreDataManager.context.fetch(fetchRequest)
            if let chatEntityToDelete = chatEntities.first {
                coreDataManager.context.delete(chatEntityToDelete)
                coreDataManager.saveContext()
                fetchData()
            }
        } catch {
            print("Failed to delete chat: \(error)")
        }
    }
    
    func addMessage(to chat: AppChat, message: AppMessage) {
        let fetchRequest: NSFetchRequest<ChatEntity> = ChatEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", chat.id)
        
        do {
            let chatEntities = try coreDataManager.context.fetch(fetchRequest)
            if let chatEntity = chatEntities.first {
                let newMessage = MessageEntity(context: coreDataManager.context)
                newMessage.id = message.id
                newMessage.text = message.text
                newMessage.role = message.role.rawValue
                newMessage.createdAt = message.createdAt
                newMessage.chat = chatEntity
                
                coreDataManager.saveContext()
                fetchData()
            }
        } catch {
            print("Failed to add message: \(error)")
        }
    }
}
