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
    @State private var openMemberList: Bool = false
    @State private var lastMessageId: String? = nil
    @State private var shouldScrollToBottom: Bool = true
    
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
                        openMemberList.toggle()
                    } label: {
                        Image(systemName: "info.bubble.fill")
                            .foregroundColor(.black)
                            .font(.body)
                            .padding(.trailing)
                    }
                }
                .frame(height: 60)
                .background(Color("primary-color"))
                
                ScrollViewReader { proxy in
                    ScrollView {
                        ForEach(groupchatManager.messages, id: \.id) { message in
                            GroupMessageBubble(message: message)
                                .padding(.horizontal)
                                .id(message.id)
                        }
                    }
                    .padding(.top, 10)
                    .background(.white)
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
