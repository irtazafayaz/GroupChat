//
//  PrivateChatView.swift
//  GroupChat
//
//  Created by Irtaza Fiaz on 06/04/2024.
//

import SwiftUI

struct PrivateChatView: View {
    
    // MARK: Data Members
    private var selectedUser: String

    // MARK: Data Managers
    @EnvironmentObject private var sessionManager: SessionManager
    @StateObject private var messagesManager = MessagesManager()
    
    init(selectedUser: String) {
        self.selectedUser = selectedUser
    }
    
    var body: some View {
        VStack {
            VStack {
                TitleRow()
                ScrollViewReader { proxy in
                    ScrollView {
                        ForEach(messagesManager.messages, id: \.id) { message in
                            MessageBubble(message: message)
                        }
                    }
                    .padding(.top, 10)
                    .background(Color.white)
                    .cornerRadius(30, corners: [.topLeft, .topRight])
                    .onChange(of: messagesManager.lastMessageId) {
                        proxy.scrollTo(messagesManager.lastMessageId, anchor: .bottom)
                    }
                }
            }
            .background(Color("primary-color"))
            
            MessageField(selectedUser: selectedUser)
                .environmentObject(messagesManager)
        }
        .onAppear {
            if let user = sessionManager.getCurrentAuthUser()?.uid {
                messagesManager.startOrRetrieveChat(senderId: user, receiverId: selectedUser)
            }
        }
    }
}
