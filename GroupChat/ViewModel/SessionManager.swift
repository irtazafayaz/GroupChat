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


class SessionManager: ObservableObject {
    
    @Published var authState: AuthState = .login
    
    private var cancellables = Set<AnyCancellable>()
    private let db = Firestore.firestore()
    
    @Published var userName: String = ""
    @Published var userEmail: String = ""
    @Published var userProfileImageUrl: URL?
    @Published var userFriends: [UserDetails] = []
    @Published var isLoading: Bool = false
    
    
    init() {
        self.observeAuthChanges()
        self.fetchUserData()
    }
    
    func fetchUserData() {
        guard let currentUser = Auth.auth().currentUser else { return }
        let userRef = db.collection("users").document(currentUser.uid)
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                self.userName = data?["displayName"] as? String ?? "NaN"
                self.userEmail = data?["email"] as? String ?? "NaN"
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
        isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            self.isLoading = false
            if let error = error {
                print("Error signing in: \(error.localizedDescription)")
                return
            }
        }
    }
    
    func register(email: String, password: String, fullName: String) {
        isLoading = true
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.isLoading = false
                print("Error signing up: \(error.localizedDescription)")
                return
            }
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = fullName
            changeRequest?.commitChanges(completion: { error in
                if let error = error {
                    self.isLoading = false
                    print("Error updating user's display name: \(error.localizedDescription)")
                } else {
                    self.isLoading = false
                    print("User display name updated successfully")
                }
            })
        }
    }
    
    func createNewUser(name: String, email: String, photo: UIImage?, password: String) {
        isLoading = true
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                self.isLoading = false
                print("Login error: \(error.localizedDescription)")
                return
            }
            
            let imageName = UUID().uuidString
            let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).jpg")
            
            guard let uid = result?.user.uid else {
                self.isLoading = false
                return
            }
            
            if let uploadData = photo?.jpegData(compressionQuality: 0.1) {
                storageRef.putData(uploadData, metadata: nil, completion: { (_, error) in
                    if let error = error {
                        self.isLoading = false
                        print(error)
                        return
                    }
                    storageRef.downloadURL(completion: { (url, error) in
                        if let error = error {
                            self.isLoading = false
                            print(error)
                            return
                        }
                        guard let photoUrl = url else {
                            self.isLoading = false
                            return
                        }
                        let values = ["displayName": name, "email": email, "photoURL": photoUrl.absoluteString]
                        
                        let groupDocument = self.db.collection("users").document(uid)
                        groupDocument.setData(values) { err in
                            if let err = err {
                                self.isLoading = false
                                print("Error sending message: \(err)")
                            } else {
                                self.isLoading = false
                                print("User Created")
                            }
                        }
                    })
                })
            }
        }
    }
    
    func logout() {
        do {
            userProfileImageUrl = nil
            userFriends = []
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
                    print(self?.userFriends as Any)
                }
                
            } else {
                print("Document does not exist or failed to fetch friends list")
            }
        }
    }
    
    func updateUserProfilePicture(newPhoto: UIImage, completion: @escaping (Bool, Error?) -> Void) {
        guard let userid = getCurrentAuthUser()?.uid else { return }
        let imageName = UUID().uuidString
        let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).jpg")
        
        if let uploadData = newPhoto.jpegData(compressionQuality: 0.1) {
            // Upload the image data to Firebase Storage
            storageRef.putData(uploadData, metadata: nil) { (_, error) in
                if let error = error {
                    print("Error uploading image: \(error.localizedDescription)")
                    completion(false, error)
                    return
                }
                
                // Retrieve the download URL of the uploaded image
                storageRef.downloadURL { (url, error) in
                    if let error = error {
                        print("Error fetching image URL: \(error.localizedDescription)")
                        completion(false, error)
                        return
                    }
                    
                    guard let newPhotoUrl = url else {
                        completion(false, NSError(domain: "URLCreationError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not create URL for uploaded photo."]))
                        return
                    }
                    
                    // Update the Firestore document with the new image URL
                    let values = ["photoURL": newPhotoUrl.absoluteString]
                    self.userProfileImageUrl = newPhotoUrl
                    let userDocument = self.db.collection("users").document(userid)
                    
                    userDocument.updateData(values) { error in
                        if let error = error {
                            print("Error updating user profile picture: \(error)")
                            completion(false, error)
                        } else {
                            print("Profile picture updated successfully.")
                            completion(true, nil)
                        }
                    }
                }
            }
        } else {
            // Handle the case where the image could not be converted to JPEG data
            completion(false, NSError(domain: "ImageDataError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not convert image to JPEG data."]))
        }
    }
    
    
    
}

