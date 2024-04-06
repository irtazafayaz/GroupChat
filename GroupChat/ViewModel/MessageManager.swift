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

    let db = Firestore.firestore()

    func startOrRetrieveChat(senderId: String, receiverId: String) {
        
        let chatsRef = db.collection("Chats")
        let query = chatsRef.whereField("participants", arrayContains: senderId)
        
        query.getDocuments(completion: { [weak self] snapshot, error in
            
            guard let self = self else { return }
            if let error = error {
                print("Error finding chats: \(error.localizedDescription)")
                return
            }
            
            let existingChat = snapshot?.documents.first { docSnapshot in
                let participants = docSnapshot.get("participants") as? [String] ?? []
                
                if participants.contains(receiverId) {
                    self.chatId = docSnapshot.documentID
                    self.getMessages()
                    return true
                }
                return false
            }
            
            if (existingChat == nil) {
                // No chat exists, create a new chat document
                let newChatRef = chatsRef.document()
                self.chatId = newChatRef.documentID
                newChatRef.setData([
                    "participants": [senderId, receiverId]
                ]) { error in
                    if let error = error {
                        print("Error creating new chat: \(error.localizedDescription)")
                    } else {
                        print("Chat Started")
                        self.getMessages()
                    }
                }
            }
        })
    }
    
    func sendMessage(senderId: String, receiverId: String, message: String) {
        let collection = db.collection("Chats").document(chatId).collection("messages")
        let document = collection.document()
        document.setData([
            "senderId": senderId,
            "receiverId": receiverId,
            "message": message,
            "timestamp": FieldValue.serverTimestamp()
        ]) { error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
            } else {
                print("Message sent successfully")
            }
        }
    }
    
    
    func getMessages() {
        if !chatId.isEmpty {
            

        db.collection("Chats").document(chatId).collection("messages").addSnapshotListener { querySnapshot, error in
            
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(String(describing: error))")
                return
            }
            self.messages = documents.compactMap { document -> Message? in
                do {
                    return try document.data(as: Message.self)
                } catch {
                    print("Error decoding document into Message: \(error)")
                    return nil
                }
            }
            self.messages.sort { $0.timestamp < $1.timestamp }
            if let id = self.messages.last?.id {
                self.lastMessageId = id
            }
        }
        }
    }
    
}
