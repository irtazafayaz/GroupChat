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
    @Published var members: [UserDetails] = []
    @Published private(set) var friendAddedAlertMessage: String = ""
    @Published var friendAddedAlert: Bool = false
    @Published var lastMessageId: String? = nil
    
    private let db = Firestore.firestore()
    private var messagesListener: ListenerRegistration?
    private var groupListener: ListenerRegistration?
    
    deinit {
        messagesListener?.remove()
        groupListener?.remove()
    }
    
    func sendMessage(toGroup groupId: String, message: String, senderId: String, senderName: String) {
        FirebaseManager.shared.sendGroupMessage(toGroup: groupId, message: message, senderId: senderId, senderName: senderName)
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
            var groupMembers = group.members
            groupMembers?.append(group.owner)
            self.fetchMembers(memberIDs: groupMembers ?? [])
        }
        
        messagesListener = db.collection("groups").document(groupId).collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                self?.messages = documents.compactMap { try? $0.data(as: GroupMessage.self) }
                self?.lastMessageId = self?.messages.last?.id
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
    
    
    func addFriend(currentUserId: String, friendId: String) {
        let usersRef = db.collection("users")
        let currentUserRef = usersRef.document(currentUserId)
        let friendUserRef = usersRef.document(friendId)
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let currentUserDocument: DocumentSnapshot
            let friendUserDocument: DocumentSnapshot
            do {
                try currentUserDocument = transaction.getDocument(currentUserRef)
                try friendUserDocument = transaction.getDocument(friendUserRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                self.showAddFriendAlert("Unable to add friend")
                return nil
            }
            
            var currentUserFriends = currentUserDocument.data()?["friends"] as? [String] ?? []
            if !currentUserFriends.contains(friendId) {
                currentUserFriends.append(friendId)
                transaction.updateData(["friends": currentUserFriends], forDocument: currentUserRef)
            }
            
            var friendUserFriends = friendUserDocument.data()?["friends"] as? [String] ?? []
            if !friendUserFriends.contains(currentUserId) {
                friendUserFriends.append(currentUserId)
                transaction.updateData(["friends": friendUserFriends], forDocument: friendUserRef)
            }
            
            return nil
        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
                self.showAddFriendAlert("Unable to add friend")
            } else {
                print("Transaction successfully committed!")
                self.showAddFriendAlert("Friend Added Successfully")
            }
        }
    }
    
    private func showAddFriendAlert(_ msg: String) {
        friendAddedAlertMessage = msg
        friendAddedAlert.toggle()
    }
    
    func blockUser(currentUserId: String, userIdToBlock: String) {
            let usersRef = db.collection("users")
            let currentUserRef = usersRef.document(currentUserId)
            
            db.runTransaction({ (transaction, errorPointer) -> Any? in
                let currentUserDocument: DocumentSnapshot
                do {
                    try currentUserDocument = transaction.getDocument(currentUserRef)
                } catch let fetchError as NSError {
                    errorPointer?.pointee = fetchError
                    print("Unable to block user: \(fetchError.localizedDescription)")
                    return nil
                }
                
                var blockedUsers = currentUserDocument.data()?["blockedUsers"] as? [String] ?? []
                if !blockedUsers.contains(userIdToBlock) {
                    blockedUsers.append(userIdToBlock)
                    transaction.updateData(["blockedUsers": blockedUsers], forDocument: currentUserRef)
                }
                
                return nil
            }) { (object, error) in
                if let error = error {
                    print("Transaction failed: \(error.localizedDescription)")
                } else {
                    print("User successfully blocked!")
                }
            }
        }
        
        func reportMessage(_ message: GroupMessage, senderId: String) {
            let reportData = [
                "reportedBy": senderId,
                "messageId": message.id ?? "",
                "senderId": message.senderId,
                "message": message.content,
                "timestamp": FieldValue.serverTimestamp()
            ] as [String : Any]

            db.collection("group-reports").addDocument(data: reportData) { error in
                if let error = error {
                    print("Error reporting message: \(error.localizedDescription)")
                } else {
                    print("Message reported successfully")
                    self.blockUser(currentUserId: senderId, userIdToBlock: message.senderId)
                }
            }
        }
    
    
    
    func leaveGroup(groupId: String, userId: String, completion: @escaping (Error?) -> Void) async {
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
                // Remove the user from the members array and update the database.
                members.remove(at: index)
                groupData["members"] = members
                transaction.updateData(["members": members], forDocument: groupRef)
            } else {
                // User is not a member, nothing to do.
                let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "User is not a member of the group."])
                errorPointer?.pointee = error
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
    
    
}

