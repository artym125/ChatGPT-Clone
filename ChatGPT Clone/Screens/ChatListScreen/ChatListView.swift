//
//  ChatListView.swift
//  ChatGPT Clone
//
//  Created by Ostap Artym on 28.08.2024.
//

import SwiftUI

struct ChatListView: View {
    @EnvironmentObject var appState: AppState
    @StateObject var vm = ChatListViewModel()
    
    var body: some View {
        VStack {
            switch vm.loadingState {
            case .loading, .none:
                Text("Loading chats...")
            case .noResult:
                Text("No chats...")
            case .resultFound:
                List {
                    ForEach(vm.chats) { chat in
                        NavigationLink(value: chat.id) {
                            VStack(alignment: .leading) {
                                Text(chat.title)
                                    .font(.headline)
                                Text(chat.subtitle ?? "...")
                                    .font(.subheadline)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { index in
                            let chat = vm.chats[index]
                            vm.deleteChat(chat: chat)
                        }
                    }
                }
            }
        }
        .navigationTitle("Chats")
        .navigationDestination(for: String.self) { chatId in
            ChatView(viewModel: .init(chatId: chatId))
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    let newChat = AppChat(
                        id: UUID().uuidString,
                        title: "New Chat",
                        subtitle: nil,  // Or use an empty string if you prefer
                        model: "gpt-4o-mini",  // Correctly pass the enum value
                        lastMessageSend: Date(),
                        owner: "OwnerID"
                    )
                    vm.createChat(chat: newChat)  // Create the chat
                    
                    // Update the navigation path to include the new chat ID
                    appState.navigationPath.append(newChat.id)
                }) {
                    Image(systemName: "plus")
                }
            }
        }
    }
}
