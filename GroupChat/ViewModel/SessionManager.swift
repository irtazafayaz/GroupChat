//
//  SessionManager.swift
//  GroupChat
//
//  Created by Irtaza Fiaz on 21/03/2024.
//

import Foundation
import FirebaseFirestore
import Firebase
import FirebaseAuth
import Combine
import FirebaseStorage

enum AuthState {
    case login
    case home
    case register
}


final class SessionManager: ObservableObject {
    
    @Published var authState: AuthState = .login

    private var cancellables = Set<AnyCancellable>()
    private let db = Firestore.firestore()

    @Published var userName: String = ""
    @Published var userProfileImageUrl: URL?
    @Published var userFriends: [UserDetails] = []

    init() {
        self.observeAuthChanges()
        self.fetchUserData()
    }
    
    private func fetchUserData() {
        guard let currentUser = Auth.auth().currentUser else { return }
        let userRef = db.collection("users").document(currentUser.uid)
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                self.userName = data?["displayName"] as? String ?? "No Name"
                if let urlString = data?["photoURL"] as? String, let url = URL(string: urlString) {
                    self.userProfileImageUrl = url
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    private func observeAuthChanges() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                if let _ = user {
                    self?.authState = .home
                } else {
                    self?.authState = .login
                }
            }
        }
    }
    
    func login(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Error signing in: \(error.localizedDescription)")
                return
            }
        }
    }
    
    func register(email: String, password: String, fullName: String) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Error signing up: \(error.localizedDescription)")
                return
            }
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = fullName
            changeRequest?.commitChanges(completion: { error in
                if let error = error {
                    print("Error updating user's display name: \(error.localizedDescription)")
                    // Handle error, if necessary
                } else {
                    print("User display name updated successfully")
                    // Handle success, if necessary
                }
            })
        }
    }
    
    func createNewUser(name: String, email: String, photo: UIImage?, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("Login error: \(error.localizedDescription)")
                return
            }
            
            let imageName = UUID().uuidString
            let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).jpg")
            
            guard let uid = result?.user.uid else { return }
            
            if let uploadData = photo?.jpegData(compressionQuality: 0.1) {
                storageRef.putData(uploadData, metadata: nil, completion: { (_, error) in
                    if let error = error {
                        print(error)
                        return
                    }
                    storageRef.downloadURL(completion: { (url, error) in
                        if let error = error {
                            print(error)
                            return
                        }
                        guard let photoUrl = url else { return }
                        let values = ["displayName": name, "email": email, "photoURL": photoUrl.absoluteString]

                        let groupDocument = self.db.collection("users").document(uid)
                        groupDocument.setData(values) { err in
                            if let err = err {
                                print("Error sending message: \(err)")
                            } else {
                                print("Message sent")
                            }
                        }
                    })
                })
            }
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    func getCurrentAuthUser() -> User? {
        return Auth.auth().currentUser
    }
    
    func fetchUserFriends() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("No logged-in user")
            return
        }

        let currentUserRef = db.collection("users").document(currentUserID)

        currentUserRef.getDocument { [weak self] (document, error) in
            if let document = document, document.exists, let data = document.data(), let friendIDs = data["friends"] as? [String] {
                var friendsDetails: [UserDetails] = []

                let fetchGroup = DispatchGroup()

                for friendID in friendIDs {
                    fetchGroup.enter()
                    let friendRef = self?.db.collection("users").document(friendID)
                    friendRef?.getDocument { (friendDoc, error) in
                        if let friendDoc = friendDoc, friendDoc.exists, let friend = try? friendDoc.data(as: UserDetails.self) {
                            friendsDetails.append(friend)
                        } else {
                            print("Could not fetch friend details for ID: \(friendID)")
                        }
                        fetchGroup.leave()
                    }
                }

                fetchGroup.notify(queue: .main) {
                    self?.userFriends = friendsDetails
                    print(self?.userFriends)
                }

            } else {
                print("Document does not exist or failed to fetch friends list")
            }
        }
    }

    
    
}

