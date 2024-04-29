//
//  PrivateChatView.swift
//  GroupChat
//
//  Created by Irtaza Fiaz on 06/04/2024.
//

import SwiftUI

struct PrivateChatView: View {
    
    // MARK: Data Members
    private var receiverId: String
    
    // MARK: Data Managers
    @EnvironmentObject private var sessionManager: SessionManager
    @StateObject private var messagesManager = MessagesManager()
    
    init(receiverId: String) {
        self.receiverId = receiverId
    }
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    CustomBackButton()
                    if let receiver = messagesManager.receiverInfo {
                        if let url = URL(string: receiver.photoURL) {
                            CachedAsyncImageView(url: url)
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 30, height: 30)
                                .clipShape(Circle())
                                .padding(.leading, 5)
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 30, height: 30)
                                    .cornerRadius(30)
                                    .padding(.leading, 5)
                        }
                        Text(receiver.displayName.uppercased())
                            .font(.custom(FontFamily.bold.rawValue, size: 20))
                    }
                    Spacer()
                }
                .frame(height: 60)
                .background(Color("primary-color"))

                
                ScrollViewReader { proxy in
                    ScrollView {
                        ForEach(messagesManager.messages, id: \.id) { message in
                            MessageBubble(message: message)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.top, 10)
                    .background(Color.white)
                    .cornerRadius(10, corners: [.topLeft, .topRight])
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            if let lastId = messagesManager.messages.last?.id {
                                proxy.scrollTo(lastId, anchor: .bottom)
                            }
                        }
                    }
                    .onChange(of: messagesManager.messages.last?.id) { scrollToBottom(proxy: proxy) }

                }
                Spacer()
            }
            
            MessageField(receiverId: receiverId)
                .environmentObject(messagesManager)
        }
        .onAppear {
            if let user = sessionManager.getCurrentAuthUser()?.uid {
                messagesManager.startOrRetrieveChat(senderId: user, receiverId: receiverId)
                messagesManager.fetchFriendInfo(receiverId: receiverId)
            }
        }
        .navigationBarBackButtonHidden()
        .frame(maxWidth: .infinity)
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        guard let id = messagesManager.messages.last?.id else { return }
        proxy.scrollTo(id, anchor: .bottomTrailing)
    }
    
}
