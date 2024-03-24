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
    
    var body: some View {
        HStack {
            
            CustomTextField(placeholder: Text("Enter your message here"), text: $message)
                .frame(height: 52)
                .disableAutocorrection(true)
            
            Button {
                groupManager.sendMessage(toGroup: groupId, message: message, senderId: senderId)
                message = ""
                
            } label: {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color("Peach"))
                    .cornerRadius(50)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color("Gray"))
        .cornerRadius(50)
        .padding()
    }
    
}

#Preview {
    GroupMsgField(groupId: "", senderId: "")
}