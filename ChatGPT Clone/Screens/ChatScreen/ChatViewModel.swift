//
//  ChatViewModel.swift
//  ChatGPT Clone
//
//  Created by Ostap Artym on 28.08.2024.
//

import CoreData
import OpenAI
import SwiftUI

// Модель чату
class ChatViewModel: ObservableObject {
    @Published var chat: AppChat
    @Published var messages: [AppMessage] = []
    @Published var messageText: String = ""
    let chatId: String

    private var coreDataManager = CoreDataManager.shared

    init(chatId: String) {
        self.chatId = chatId
        self.chat = AppChat(id: chatId,
                            title: "",
                            subtitle: "",
                            model: "gpt-4o-mini",
                            lastMessageSend: Date(),
                            owner: "")
    }

    func fetchData() {
        // Запит для отримання даних чату
        let fetchRequest: NSFetchRequest<ChatEntity> = ChatEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", chatId)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastMessageSend", ascending: true)]

        do {
            let chatEntities = try coreDataManager.context.fetch(fetchRequest)
            print("Fetched chat entities: \(chatEntities.count)")
            if let chatEntity = chatEntities.first {
                DispatchQueue.main.async { [weak self] in
                    self?.chat = AppChat(entity: chatEntity)
                    // Сортуємо повідомлення за createdAt, щоб уникнути проблем з порядком
                    self?.messages = (self?.chat.messages ?? []).sorted(by: { $0.createdAt < $1.createdAt })
                    print("Fetched messages: \(self?.messages ?? [])")
                }
            }
        } catch {
            print("Failed to fetch chat: \(error)")
        }
    }


    func sendMessage() {
        Task {
            guard !messageText.isEmpty else { return }

            // Створення нового повідомлення
            let newMessage = AppMessage(id: UUID().uuidString, text: messageText, role: .user, createdAt: Date())
            
            // Оновлення повідомлень на основному потоці
            await MainActor.run {
                messages.append(newMessage)
                print("Appended new message: \(newMessage)")
                messageText = ""
            }
            
            // Збереження нового повідомлення у Core Data
            saveMessage(newMessage)

            // Генерація відповіді через OpenAI API
            do {
                try await generateResponse(for: newMessage)
            } catch {
                print("Failed to generate response: \(error)")
            }
        }
    }

    private func saveMessage(_ message: AppMessage) {
        let fetchRequest: NSFetchRequest<ChatEntity> = ChatEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", chatId)

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
                print("Message saved: \(message)")
            } else {
                print("No chat entity found with id: \(chatId)")
            }
        } catch {
            print("Failed to save message: \(error)")
        }
    }
    
    private func generateResponse(for message: AppMessage) async throws {
        #warning("NEED API-KEY")
        let openAI = OpenAI(apiToken: "API-KEY")
        let queryMessages = messages.map { appMessage in
            Chat(role: appMessage.role, content: appMessage.text)
        }
        let query = ChatQuery(model: chat.model, messages: queryMessages)
        
        for try await result in openAI.chatsStream(query: query) {
            guard let newText = result.choices.first?.delta.content else { continue }
            await MainActor.run {
                if let lastMessage = messages.last, lastMessage.role != .user {
                    messages[messages.count - 1].text += newText
                } else {
                    let newMessage = AppMessage(id: result.id, text: newText, role: .assistant, createdAt: Date())
                    messages.append(newMessage)
                }
            }
        }
        
        // Зберігаємо відповідь від асистента після отримання
        if let lastMessage = messages.last {
            saveMessage(lastMessage)
        }
    }
}
