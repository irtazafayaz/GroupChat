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
    
    private var groupId: String
    
    init(groupId: String) {
        self.groupId = groupId
        groupchatManager.getMessages(forGroup: groupId)
    }

    var body: some View {
        VStack {
            VStack {
                HStack {
                    CustomBackButton()
                    TitleRow()
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
            .background(Color("Peach"))
            
            if let user = sessionManager.getCurrentAuthUser() {
                GroupMsgField(groupId: groupId, senderId: user.uid)
                    .environmentObject(groupchatManager)
            }
            
        }
        .navigationBarBackButtonHidden()
        
    }
    
}

#Preview {
    GroupChatView(groupId: "")
}
