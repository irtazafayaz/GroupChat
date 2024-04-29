//
//  GroupMsgField.swift
//  GroupChat
//
//  Created by Irtaza Fiaz on 23/03/2024.
//

import SwiftUI

struct GroupMsgField: View {
    
    @EnvironmentObject var groupManager: GroupChatVM
    @State private var message = ""
    
    var groupId: String
    var senderId: String
    var senderName: String
    
    var body: some View {
        HStack {
            
            CustomTextField(label: $message, textfieldType: .normal)

            Button {
                groupManager.sendMessage(toGroup: groupId, message: message, senderId: senderId, senderName: senderName)
                message = ""
                
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
    
}

#Preview {
    GroupMsgField(groupId: "", senderId: "", senderName: "")
}
