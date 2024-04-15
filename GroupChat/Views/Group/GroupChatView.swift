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
                        }
                    }
                    .padding(.top, 10)
                    .background(.white)
                    .cornerRadius(10, corners: [.topLeft, .topRight])
                    .onChange(of: groupchatManager.lastMessageId) {
                        withAnimation {
                            proxy.scrollTo(groupchatManager.lastMessageId, anchor: .bottom)
                        }
                    }
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
        .navigationBarBackButtonHidden()
        
    }
    
}
