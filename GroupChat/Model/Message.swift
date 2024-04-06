//
//  Message.swift
//  GroupChat
//
//  Created by Irtaza Fiaz on 21/03/2024.
//

import Foundation
import FirebaseAuth
import Firebase
import FirebaseFirestore

struct Message: Identifiable, Codable {
    @DocumentID var id: String?
    var message: String
    var receiverId: String
    var senderId: String
    var timestamp: Date
}

struct UserInfo: Identifiable, Codable {
    var id: String
    var senderId: String
    var senderName: String
}

struct GroupMessage: Identifiable, Codable {
    @DocumentID var id: String?
    var senderId: String
    var senderName: String
    var timestamp: Date
    var content: String
}

struct Group: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var type: String
    var description: String
    var owner: String
    var image: String
    var members: [String]?
}

struct UserDetails: Identifiable, Codable {
    @DocumentID var id: String?
    var displayName: String
    var email: String
    var photoURL: String
    var friends: [String]? // Add this line

}
