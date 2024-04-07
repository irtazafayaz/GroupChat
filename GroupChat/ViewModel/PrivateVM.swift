//
//  PrivateVM.swift
//  GroupChat
//
//  Created by Irtaza Fiaz on 06/04/2024.
//

import Foundation
import Firebase
import FirebaseFirestore
import SwiftUI

class PrivateVM: ObservableObject {
    
    @Published var members: [UserDetails] = []
    
    @Published var isLoading: Bool = false
    @Published var showingAddGroupView = false
    @Published var openDiscoverGroupsView = false
    @Published var isFetchingGroups = false
    @Published var filteredGroups: [Group] = []
    
    private let db = Firestore.firestore()
    
    func startOrRetrieveChat(senderId: String) {
        members.removeAll()
        isLoading = false
        db.collection("Chats")
            .whereField("participants", arrayContains: senderId)
            .getDocuments { [weak self] snapshot, error in
                
                guard let self = self, let snapshot = snapshot, error == nil else {
                    print("Error fetching chat: \(error?.localizedDescription ?? "Unknown error")")
                    self?.isLoading.toggle()
                    return
                }
                for document in snapshot.documents {
                    if let participants = document.data()["participants"] as? [String],
                       let receiverId = participants.first(where: { $0 != senderId }) {
                        self.fetchFriendInfo(receiverId: receiverId)
                    }
                }
                self.isLoading.toggle()
            }
    }
    
    func fetchFriendInfo(receiverId: String) {
        db.collection("users").document(receiverId).getDocument { [weak self] (document, error) in
            guard let document = document, document.exists, let user = try? document.data(as: UserDetails.self) else {
                print("Error fetching user: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            DispatchQueue.main.async {
                self?.members.append(user)
            }
        }
    }
    
    
}
