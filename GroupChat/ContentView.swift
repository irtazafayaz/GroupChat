//
//  ContentView.swift
//  GroupChat
//
//  Created by Irtaza Fiaz on 21/03/2024.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var sessionManager = SessionManager()
    
    var body: some View {
        NavigationView {
            switch sessionManager.authState {
            case .login:
                LoginView()
                    .environmentObject(sessionManager)
            case .register:
                RegisterView()
                    .environmentObject(sessionManager)
            case .home:
                PrivateMsgView()
                    .environmentObject(sessionManager)
            }
        }
    }
}

#Preview {
    ContentView()
}
