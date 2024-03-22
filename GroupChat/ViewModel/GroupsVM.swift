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
    @Published var isLoading: Bool = false
    @Published var showingAddGroupView = false

    private let db = Firestore.firestore()
    
    func createGroup(_ group: Group) {
        
        let group: [String: Any] = [
            "name": group.name,
            "type": group.type,
            "description":  group.description,
            "owner": group.owner
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
            isLoading.toggle()
            print("Grouped Messages\n \(groupsArray)")
        }
        
        
        
    }
    
    
}
