//
//  GroupsVM.swift
//  GroupChat
//
//  Created by Irtaza Fiaz on 22/03/2024.
//

import Foundation
import Firebase
import FirebaseFirestore
import SwiftUI

class GroupsVM: ObservableObject {
    
    @Published var groupsArray: [Group] = []
    @Published var ownedOrJoinedGroups: [Group] = []
    @Published var notJoinedGroups: [Group] = []
    
    @Published var isLoading: Bool = false
    @Published var showingAddGroupView = false
    @Published var openDiscoverGroupsView = false

    private let db = Firestore.firestore()
    
    func createGroup(_ group: Group) {
        
        let group: [String: Any] = [
            "name": group.name,
            "type": group.type,
            "description":  group.description,
            "owner": group.owner,
            "members": []
        ]
        
        self.db.collection("groups").addDocument(data: group) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added")
            }
        }
    }
    
    func fetchGroupsByOwner(_ user: String) {
        isLoading.toggle()
        groupsArray.removeAll()
        
        db.collection("groups").getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            guard let documents = querySnapshot?.documents else { return }
            
            let groups = documents.compactMap { document -> Group? in
                try? document.data(as: Group.self)
            }
            groupsArray = groups
            categorizeGroups(user)
            isLoading.toggle()
            print("Grouped Messages\n \(groupsArray)")
        }
    }
    
    func categorizeGroups(_ currentUserID: String) {
        for group in groupsArray {
            if group.owner == currentUserID || ((group.members?.contains(currentUserID)) != nil) {
                ownedOrJoinedGroups.append(group)
            } else {
                notJoinedGroups.append(group)
            }
        }
    }

    func joinGroup(groupId: String, userId: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
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
                // User is already a member or owner, do not proceed with adding.
                return nil
            } else {
                // Add the user to the members array and update the database.
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
    
    
}
