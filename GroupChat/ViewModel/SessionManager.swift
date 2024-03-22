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

enum AuthState {
    case login
    case home
    case register
}


final class SessionManager: ObservableObject {
    
    @Published var authState: AuthState = .login

    private var cancellables = Set<AnyCancellable>()

    init() {
        self.observeAuthChanges()
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
    
    func register(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Error signing up: \(error.localizedDescription)")
                return
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
    
    
}

