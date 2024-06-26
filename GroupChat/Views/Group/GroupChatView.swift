//
//  GroupChatView.swift
//  GroupChat
//
//  Created by Irtaza Fiaz on 23/03/2024.
//

import SwiftUI

struct GroupChatView: View {
    
    @ObservedObject var groupchatManager = GroupChatVM()
    @EnvironmentObject var sessionManager: SessionManager
    @Environment(\.dismiss) private var dismiss

    
    @State private var openMemberList: Bool = false
    @State private var lastMessageId: String? = nil
    @State private var shouldScrollToBottom: Bool = true
    @State private var showAlert = false
    @State private var message = ""
    
    private var selectedGroup: Group
    
    init(selectedGroup: Group) {
        self.selectedGroup = selectedGroup
        groupchatManager.getMessagesAndMembers(forGroup: selectedGroup.id ?? "NaN")
    }
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    CustomBackButton()
                    if let url = URL(string: selectedGroup.image) {
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
                    Text(selectedGroup.name.uppercased())
                        .font(.custom(FontFamily.bold.rawValue, size: 20))
                        .foregroundStyle(.white)
                    Spacer()
                    Button {
                        showAlert.toggle()
                    } label: {
                        Image(systemName: "trash.square.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(.black)
                    }
                    .alert("are you sure you want to leave this group? 🥹", isPresented: $showAlert) {
                        Button("OK", role: .destructive) {
                            FirebaseManager.shared.leaveGroup(groupId: selectedGroup.id ?? "", userId: sessionManager.getCurrentAuthUser()?.uid ?? "") {_ in}
                            dismiss()
                        }
                    }
                    .padding(.trailing)
                    Button {
                        openMemberList.toggle()
                    } label: {
                        Image(systemName: "info.bubble.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.black)
                            .padding(.trailing)
                    }
                }
                .frame(height: 60)
                .background(Color("primary-color"))
                
                ScrollViewReader { proxy in
                    ScrollView {
                        ForEach(groupchatManager.messages, id: \.id) { message in
                            GroupMessageBubble(message: message, groupId: selectedGroup.id ?? "") {
                                groupchatManager.reportMessage(message, senderId: sessionManager.getCurrentAuthUser()?.uid ?? "")
                            }.padding(.horizontal).id(message.id)
                        }
                    }
                    .padding(.top, 10)
                    .background(Color("app-background"))
                    .cornerRadius(10, corners: [.topLeft, .topRight])
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            if shouldScrollToBottom, let lastId = groupchatManager.messages.last?.id {
                                proxy.scrollTo(lastId, anchor: .bottom)
                            }
                        }
                    }
                    .onChange(of: groupchatManager.messages.last?.content) { scrollToBottom(proxy: proxy) }
                }
                
            }
            .sheet(isPresented: $openMemberList) {
                GroupMembersView()
                    .environmentObject(groupchatManager)
                    .presentationDetents([.medium, .large])
            }
            
            if let user = sessionManager.getCurrentAuthUser() {
                GroupMsgField(groupId: selectedGroup.id ?? "NaN", senderId: user.uid, senderName: user.email ?? "NaN")
                    .environmentObject(groupchatManager)
            }
            
        }
        .background(Color("app-background"))
        .navigationBarBackButtonHidden()
        .onReceive(groupchatManager.$lastMessageId) { newId in
            self.lastMessageId = newId
        }
        
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        guard let id = groupchatManager.messages.last?.id else { return }
        proxy.scrollTo(id, anchor: .bottomTrailing)
    }
    
}

#Preview {
    GroupChatView(selectedGroup: Group(name: "", type: "", description: "", owner: "", image: ""))
        .environmentObject(SessionManager())
}
