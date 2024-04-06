//
//  MessageManager.swift
//  GroupChat
//
//  Created by Irtaza Fiaz on 21/03/2024.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class MessagesManager: ObservableObject {
    
    @Published private(set) var messages: [Message] = []
    @Published private(set) var lastMessageId: String = ""
    @Published private(set) var chatId: String = ""
    @Published private(set) var receiverInfo: UserDetails?

    private let db = Firestore.firestore()
    
    func startOrRetrieveChat(senderId: String, receiverId: String) {
        db.collection("Chats")
            .whereField("participants", arrayContains: senderId)
            .getDocuments { [weak self] snapshot, error in
                
                guard let self = self, error == nil else { return }
                
                if let chatDoc = snapshot?.documents.first(where: { ($0["participants"] as? [String])?.contains(receiverId) ?? false }) {
                    self.chatId = chatDoc.documentID
                    self.getMessages()
                    
                } else {
                    let newChatRef = self.db.collection("Chats").document()
                    self.chatId = newChatRef.documentID
                    newChatRef.setData(["participants": [senderId, receiverId]]) { error in
                        if error == nil { self.getMessages() }
                    }
                }
            }
    }
    
    func sendMessage(senderId: String, receiverId: String, message: String) {
        
        guard !chatId.isEmpty else { return }
        let data = [
            "senderId": senderId,
            "receiverId": receiverId,
            "message": message,
            "timestamp": FieldValue.serverTimestamp()
        ] as [String : Any]
        
        db.collection("Chats").document(chatId).collection("messages").addDocument(data: data)
        
    }
    
    func getMessages() {
        
        guard !chatId.isEmpty else { return }
        db.collection("Chats").document(chatId).collection("messages").addSnapshotListener { [weak self] querySnapshot, error in
            
            guard let self = self, error == nil else { return }
            
            self.messages = querySnapshot?.documents.compactMap {
                try? $0.data(as: Message.self)
            }.sorted { $0.timestamp < $1.timestamp } ?? []
            
            self.lastMessageId = self.messages.last?.id ?? ""
            
        }
    }
    
    func fetchFriendInfo(receiverId: String) {
        db.collection("users").document(receiverId).getDocument { [weak self] (document, error) in
            guard let document = document, document.exists, let user = try? document.data(as: UserDetails.self) else {
                print("Error fetching user: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            DispatchQueue.main.async {
                self?.receiverInfo = user
            }
        }
    }
    
}
