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
    @State private(set) var messages: [Message] = []
    @State private(set) var lastMessageId: String = ""
    @State private(set) var chatId: String = ""
    @State private(set) var receiverInfo: UserDetails?
    @State private var showAlert = false
    @State private var message = ""

    @EnvironmentObject private var sessionManager: SessionManager
    @Environment(\.dismiss) private var dismiss
    
    init(receiverId: String) {
        self.receiverId = receiverId
    }
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    CustomBackButton()
                    if let receiver = receiverInfo {
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
                            .foregroundStyle(.white)
                    }
                    Spacer()
                    
                    Button {
                        showAlert.toggle()
                    } label: {
                        Image(systemName: "trash.square.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(.white)
                            .padding(.trailing)
                    }
                    .alert("are you sure you want to block your friend? 🥹", isPresented: $showAlert) {
                        Button("OK", role: .destructive) {
                            FirebaseManager.shared.stopChattingWithFriend(chatId: chatId)
                            FirebaseManager.shared.removeFriend(currentUserId: sessionManager.getCurrentAuthUser()?.uid ?? "", friendId: receiverId)
                            dismiss()
                        }
                    }
                }
                .frame(height: 60)
                .background(Color("primary-color"))

                
                ScrollViewReader { proxy in
                    ScrollView {
                        ForEach(messages, id: \.id) { message in
                            MessageBubble(message: message) {
                                FirebaseManager.shared.reportMessage(message, senderId: sessionManager.getCurrentAuthUser()?.uid ?? "")
                            }.padding(.horizontal)

                        }
                    }
                    .background(Color("app-background"))
                    .cornerRadius(10, corners: [.topLeft, .topRight])
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            if let lastId = messages.last?.id {
                                proxy.scrollTo(lastId, anchor: .bottom)
                            }
                        }
                    }
                    .onChange(of: messages.last?.id) { scrollToBottom(proxy: proxy) }

                }
                Spacer()
            }
            
            messageField.ignoresSafeArea()
        }
        .background(Color("app-background"))
        .onAppear {
            FirebaseManager.shared.fetchUserInfo(receiverId) { friend, error in
                if error == nil {
                    self.receiverInfo = friend
                }
            }
            if let user = sessionManager.getCurrentAuthUser()?.uid {
                FirebaseManager.shared.fetchConversationId(senderId: user, receiverId: receiverId, completion: { conversationId, error in
                    if error == nil, let convoId = conversationId {
                        chatId = convoId
                        FirebaseManager.shared.fetchConversationMessages(convoId, completion: { messages, error in
                            if error == nil {
                                self.messages = messages
                            }
                        })
                    }
                    
                })
            }
        }
        .navigationBarBackButtonHidden()
        .frame(maxWidth: .infinity)
    }
    
    var messageField: some View {
        HStack {
            CustomTextField(label: $message, textfieldType: .normal)
            Button {
                if let user = sessionManager.getCurrentAuthUser()?.uid {
                    FirebaseManager.shared.sendPrivateMessage(senderId: user, receiverId: receiverId, message: message, chatId: chatId)
                    message = ""
                }
                
            } label: {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color("primary-color"))
                    .cornerRadius(50)
            }
        }
        .padding()
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        guard let id = messages.last?.id else { return }
        proxy.scrollTo(id, anchor: .bottomTrailing)
    }
    
}

#Preview {
    PrivateChatView(receiverId: "").environmentObject(SessionManager())
}
