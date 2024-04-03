//
//  GroupChatVM.swift
//  GroupChat
//
//  Created by Irtaza Fiaz on 23/03/2024.
//

import Foundation
import Firebase
import FirebaseFirestore

class GroupChatVM: ObservableObject {
    
    @Published private(set) var messages: [GroupMessage] = []
    @Published private(set) var lastMessageId: String = ""
    
    let db = Firestore.firestore()
    
    func sendMessage(toGroup groupId: String, message: String, senderId: String, senderName: String) {
        
        let messageData: [String: Any] = [
            "senderId": senderId,
            "senderName": senderName,
            "timestamp": FieldValue.serverTimestamp(),
            "content": message,
        ]
        
        let groupDocument = self.db.collection("groups").document(groupId)
        groupDocument.collection("messages").addDocument(data: messageData) { err in
            if let err = err {
                print("Error sending message: \(err)")
            } else {
                print("Message sent")
            }
        }
    }
    
    func getMessages(forGroup groupId: String) {
        db.collection("groups").document(groupId).collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { querySnapshot, error in
            
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(String(describing: error))")
                return
            }
            self.messages = documents.compactMap { document -> GroupMessage? in
                do {
                    return try document.data(as: GroupMessage.self)
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
