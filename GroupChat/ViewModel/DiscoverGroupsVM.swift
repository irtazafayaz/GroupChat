//
//  DiscoverGroupsVM.swift
//  GroupChat
//
//  Created by Irtaza Fiaz on 27/03/2024.
//

import Foundation
import Firebase
import FirebaseFirestore

final class DiscoverGroupsVM: ObservableObject {
    
    @Published var groupsArray: [Group] = []
    @Published var isLoading: Bool = false

    private let db = Firestore.firestore()
    
    func joinGroup(userid: String, groupId: String) {
        

        let joinUsersList: [String: Any] = [
            "userId": userid
        ]
        
        let groupDocument = db.collection("groups").document(groupId).collection("joined-users")
        groupDocument.addDocument(data: joinUsersList) { err in
            if let err = err {
                print("Error joinging group: \(err)")
            } else {
                print("Group Joined")
            }
        }
        
        
    }
    
    func fetchAllGroups(_ user: String) {
        
        isLoading.toggle()
        groupsArray.removeAll()
        
        let groupsReference = db.collection("groups")
        
        db.collection("groups").getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            guard let documents = querySnapshot?.documents else { return }
            
            let groups = documents.compactMap { document -> Group? in
                try? document.data(as: Group.self)
            }
            groupsArray = groups
            isLoading.toggle()
            print("Grouped Messages\n \(groupsArray)")
        }
 
    }
 
    
    func fetchGroupsByUser(_ user: String) {
        isLoading.toggle()
        groupsArray.removeAll()
        
        // Create a reference to the `groups` collection
        let db = Firestore.firestore()
        let groupsRef = db.collection("groups")
        
        // Query for groups where the user is the owner
        let ownerQuery = groupsRef.whereField("owner", isEqualTo: user)
        
        // Query for groups where the user is a member
        let memberQuery = groupsRef.whereField("members", arrayContains: user)
        
        // Use a DispatchGroup to wait for both queries to finish
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        ownerQuery.getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self, let documents = querySnapshot?.documents else {
                dispatchGroup.leave()
                return
            }
            
            let ownerGroups = documents.compactMap { document -> Group? in
                try? document.data(as: Group.self)
            }
            
            self.groupsArray.append(contentsOf: ownerGroups)
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        memberQuery.getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self, let documents = querySnapshot?.documents else {
                dispatchGroup.leave()
                return
            }
            
            let memberGroups = documents.compactMap { document -> Group? in
                try? document.data(as: Group.self)
            }
            
            // Append only unique groups that aren't already included from the owner query
            for group in memberGroups where !self.groupsArray.contains(where: { $0.id == group.id }) {
                self.groupsArray.append(group)
            }
            
            dispatchGroup.leave()
        }
        
        // Once both queries are complete, update UI accordingly
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.isLoading.toggle()
            // Optionally, sort the groupsArray if needed
            // self.groupsArray.sort(by: { $0.creationDate < $1.creationDate })
            print("Fetched Groups:\n \(self.groupsArray)")
        }
    }
    
}
