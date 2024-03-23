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
    
    func sendMessage(toGroup groupId: String, message: String, senderId: String) {
        
        let messageData: [String: Any] = [
            "senderId": senderId,
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
    
    
    func fetchMessages(forGroup groupId: String) {
        db.collection("groups").document(groupId).collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { (querySnapshot, error) in
                
                guard let documents = querySnapshot?.documents else {
                    print("No documents in 'messages'")
                    return
                }
                
                self.messages = documents.map { docSnapshot -> GroupMessage in
                    
                    let data = docSnapshot.data()
                    let id = docSnapshot.documentID
                    let senderId = data["senderId"] as? String ?? ""
                    let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                    let content = data["content"] as? String ?? ""
                    
                    return GroupMessage(senderId: senderId, timestamp: timestamp, content: content)
                }
            }
    }
    
}
