//
//  FirebaseManager.swift
//  GroupChat
//
//  Created by Jahanzaib Nadeem on 27/05/2024.
//

import Foundation
import FirebaseFirestore
import Firebase
import FirebaseAuth
import Combine
import FirebaseStorage

final class FirebaseManager: ObservableObject {
    
    // MARK: Singleton Props
    private init(){}
    static let shared = FirebaseManager()
    
    private let db = Firestore.firestore()

    @Published var userInfo: UserDetails?
    @Published var currentUser: User?

}

// MARK: - PRIVATE CHAT -

extension FirebaseManager {
    func fetchFriendListForPrivateChat(senderId: String, completion: @escaping ([String], Error?) -> Void) {
        db.collection("Chats")
            .whereField("participants", arrayContains: senderId)
            .getDocuments { [weak self] snapshot, error in
                guard let _ = self else {
                    completion([], error)
                    return
                }
                if let error = error {
                    completion([], error)
                    return
                }
                guard let snapshot = snapshot else {
                    completion([], nil)
                    return
                }
                var participantsArray = [String]()
                for document in snapshot.documents {
                    if let participants = document.data()["participants"] as? [String],
                       let receiverId = participants.first(where: { $0 != senderId }) {
                        participantsArray.append(receiverId)
                    }
                }
                completion(participantsArray, nil)
            }
    }
    
    func fetchConversationId(senderId: String, receiverId: String, completion: @escaping (String?, Error?) -> Void) {
        db.collection("Chats")
            .whereField("participants", arrayContains: senderId)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self, error == nil else {
                    completion(nil, error)
                    return
                }
                if let chatDoc = snapshot?.documents.first(where: { ($0["participants"] as? [String])?.contains(receiverId) ?? false }) {
                    completion(chatDoc.documentID, nil)
                } else {
                    let newChatRef = self.db.collection("Chats").document()
                    newChatRef.setData(["participants": [senderId, receiverId]]) { error in
                        if error == nil {
                            completion(newChatRef.documentID, nil)
                        } else {
                            completion(nil, error)
                        }
                    }
                }
            }
    }
    
    func fetchConversationMessages(_ chatId: String, completion: @escaping ([Message], Error?) -> Void) {
        db.collection("Chats").document(chatId).collection("messages").addSnapshotListener { querySnapshot, error in
            guard error == nil else {
                completion([], error)
                return
            }
            let messages = querySnapshot?.documents.compactMap { try? $0.data(as: Message.self) }
                .sorted { $0.timestamp < $1.timestamp } ?? []
            completion(messages, nil)
        }
    }
    
    func fetchUserInfo(_ id: String, completion: @escaping (UserDetails?, Error?) -> Void) {
        db.collection("users").document(id).getDocument { (document, error) in
            guard let document = document, document.exists,
                  let user = try? document.data(as: UserDetails.self) else {
                completion(nil, error)
                print("Error fetching user: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            completion(user, nil)
        }
    }
    
    func stopChattingWithFriend(chatId: String) {
        guard !chatId.isEmpty else { return }
        db.collection("Chats").document(chatId).delete { error in
            if let error = error {
                print("Error removing chat: \(error.localizedDescription)")
            } else {
                print("Chat successfully removed!")
            }
        }
    }
    
    func reportMessage(_ message: Message, senderId: String) {
        let reportData = [
            "reportedBy": senderId,
            "messageId": message.id ?? "",
            "senderId": message.senderId,
            "receiverId": message.receiverId,
            "message": message.message,
            "timestamp": FieldValue.serverTimestamp()
        ] as [String : Any]

        db.collection("reports").addDocument(data: reportData) { error in
            if let error = error {
                print("Error reporting message: \(error.localizedDescription)")
            } else {
                print("Message reported successfully")
            }
        }
    }
    
    func sendPrivateMessage(senderId: String, receiverId: String, message: String, chatId: String) {
        guard !chatId.isEmpty else { return }
        let data = [
            "senderId": senderId,
            "receiverId": receiverId,
            "message": message,
            "timestamp": FieldValue.serverTimestamp()
        ] as [String : Any]
        db.collection("Chats").document(chatId).collection("messages").addDocument(data: data)
    }
    
    func removeFriend(currentUserId: String, friendId: String) {
        let usersRef = db.collection("users")

        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let currentUserRef = usersRef.document(currentUserId)
            let friendUserRef = usersRef.document(friendId)
            
            do {
                let currentUserDocument = try transaction.getDocument(currentUserRef)
                let friendUserDocument = try transaction.getDocument(friendUserRef)
                
                if var currentUserFriends = currentUserDocument.data()?["friends"] as? [String] {
                    currentUserFriends.removeAll(where: { $0 == friendId })
                    transaction.updateData(["friends": currentUserFriends], forDocument: currentUserRef)
                }

                if var friendUserFriends = friendUserDocument.data()?["friends"] as? [String] {
                    friendUserFriends.removeAll(where: { $0 == currentUserId })
                    transaction.updateData(["friends": friendUserFriends], forDocument: friendUserRef)
                }
                
            } catch let error as NSError {
                errorPointer?.pointee = error
                return nil
            }
            
            return nil
        }) { (_, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Friend removed successfully")
            }
        }
    }

}

// MARK: GROUP CHAT
extension FirebaseManager {
    
    func fetchGroupsByOwner(_ user: String, completion: @escaping (([Group], Error?) -> Void)) {
        db.collection("groups").addSnapshotListener { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                completion([], error)
                return
            }
            let groups = documents.compactMap { document -> Group? in
                try? document.data(as: Group.self)
            }
            completion(groups, nil)
        }
    }
    
    func joinGroup(groupId: String, userId: String, completion: @escaping (Error?) -> Void) {
        let groupRef = db.collection("groups").document(groupId)
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let groupDocument: DocumentSnapshot
            do {
                try groupDocument = transaction.getDocument(groupRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard var groupData = groupDocument.data() else {
                let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch group data."])
                errorPointer?.pointee = error
                return nil
            }
            
            var members = groupData["members"] as? [String] ?? []
            if members.contains(userId) || groupData["owner"] as? String == userId {
                return nil
            } else {
                members.append(userId)
                groupData["members"] = members
                transaction.updateData(["members": members], forDocument: groupRef)
            }
            return nil
        }) { (object, error) in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    func leaveGroup(groupId: String, userId: String, completion: @escaping (Error?) -> Void) {
        let groupRef = db.collection("groups").document(groupId)

        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let groupDocument: DocumentSnapshot
            do {
                try groupDocument = transaction.getDocument(groupRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard var groupData = groupDocument.data() else {
                let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch group data."])
                errorPointer?.pointee = error
                return nil
            }
            
            var members = groupData["members"] as? [String] ?? []
            if let index = members.firstIndex(of: userId) {
                members.remove(at: index)
                groupData["members"] = members
                transaction.updateData(["members": members], forDocument: groupRef)
            } else {
                // User not in members list, no need to update anything
                return nil
            }

            return nil
        }) { (object, error) in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }

    func sendGroupMessage(toGroup groupId: String, message: String, senderId: String, senderName: String) {
        let messageData: [String: Any] = [
            "senderId": senderId,
            "senderName": senderName,
            "timestamp": FieldValue.serverTimestamp(),
            "content": message,
        ]
        
        db.collection("groups").document(groupId).collection("messages").addDocument(data: messageData) { err in
            if let err = err {
                print("Error sending message: \(err)")
            } else {
                print("Message sent")
            }
        }
    }

    
}
