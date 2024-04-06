//
//  PrivateChatView.swift
//  GroupChat
//
//  Created by Irtaza Fiaz on 06/04/2024.
//

import SwiftUI

struct PrivateChatView: View {
    
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
                    TitleRow(imageUrl: URL(string: selectedGroup.image), name: selectedGroup.name)
                        .onTapGesture {
                            openMemberList.toggle()
                        }
                }
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
            .background(Color("primary-color"))
            if let user = sessionManager.getCurrentAuthUser() {
                GroupMsgField(groupId: selectedGroup.id ?? "NaN", senderId: user.uid, senderName: user.email ?? "NaN")
                    .environmentObject(groupchatManager)
            }
            
        }
        .navigationBarBackButtonHidden()
        
    }
}
