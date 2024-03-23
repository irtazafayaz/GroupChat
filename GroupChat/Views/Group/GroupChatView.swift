//
//  GroupChatView.swift
//  GroupChat
//
//  Created by Irtaza Fiaz on 23/03/2024.
//

import SwiftUI

struct GroupChatView: View {
    
    @StateObject var groupchatManager = GroupChatVM()
    @EnvironmentObject var sessionManager: SessionManager
    
    var groupId: String
    
    init(groupId: String) {
        self.groupId = groupId
        groupchatManager.fetchMessages(forGroup: groupId)
    }

    
    var body: some View {
        VStack {
            VStack {
                TitleRow()
                
                ScrollViewReader { proxy in
                    ScrollView {
                        ForEach(groupchatManager.messages, id: \.id) { message in
                            GroupMessageBubble(message: message)
                        }
                    }
                    .padding(.top, 10)
                    .background(.white)
                    .cornerRadius(30, corners: [.topLeft, .topRight])
                    .onChange(of: groupchatManager.lastMessageId) { id in
                        withAnimation {
                            proxy.scrollTo(id, anchor: .bottom)
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
    }
    
}

#Preview {
    GroupChatView(groupId: "")
}
