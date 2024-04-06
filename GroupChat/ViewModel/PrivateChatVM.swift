//
//  PrivateChatVM.swift
//  GroupChat
//
//  Created by Irtaza Fiaz on 06/04/2024.
//

import Foundation
import Firebase
import FirebaseFirestore

class PrivateChatVM: ObservableObject {
    
    @Published private(set) var messages: [GroupMessage] = []
    @Published var members: [UserDetails] = []
    @Published private(set) var lastMessageId: String = ""
    
    private let db = Firestore.firestore()
    private var messagesListener: ListenerRegistration?
    private var groupListener: ListenerRegistration?
    
    deinit {
        messagesListener?.remove()
        groupListener?.remove()
    }
    
    func sendMessage(toGroup groupId: String, message: String, senderId: String, senderName: String) {
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
    
    func getMessagesAndMembers(forGroup groupId: String) {
        messagesListener?.remove()
        groupListener?.remove()

        groupListener = db.collection("groups").document(groupId).addSnapshotListener { [weak self] (document, error) in
            guard let self = self else { return }
            guard let document = document, document.exists, let group = try? document.data(as: Group.self) else {
                print("Error fetching group: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            self.fetchMembers(memberIDs: group.members ?? [])
        }

        messagesListener = db.collection("groups").document(groupId).collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                self?.messages = documents.compactMap { try? $0.data(as: GroupMessage.self) }
                
                if let lastMessageId = self?.messages.last?.id {
                    self?.lastMessageId = lastMessageId
                }
            }
    }

    private func fetchMembers(memberIDs: [String]) {
        members.removeAll()
        
        let memberFetchGroup = DispatchGroup()
        for memberId in memberIDs {
            memberFetchGroup.enter()
            db.collection("users").document(memberId).getDocument { [weak self] (document, error) in
                defer { memberFetchGroup.leave() }
                guard let document = document, document.exists, let user = try? document.data(as: UserDetails.self) else {
                    print("Error fetching user: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                DispatchQueue.main.async {
                    self?.members.append(user)
                }
            }
        }
        
        memberFetchGroup.notify(queue: .main) {
            print("Completed fetching all members.")
        }
    }
}
