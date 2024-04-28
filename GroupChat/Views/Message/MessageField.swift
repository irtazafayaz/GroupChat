//
//  ContentView.swift
//  GroupChat
//
//  Created by Irtaza Fiaz on 21/03/2024.
//

import SwiftUI

struct MessageField: View {
    
    @EnvironmentObject var messagesManager: MessagesManager
    @EnvironmentObject var sessionManager: SessionManager
    
    @State private var message = "Enter your message here"
    
    var receiverId: String

    var body: some View {
        HStack {

            CustomTextField(label: $message, textfieldType: .email)

//            CustomTextField(placeholder: Text("Enter your message here"), text: $message)
//                .frame(height: 52)
//                .disableAutocorrection(true)

            Button {
                if let user = sessionManager.getCurrentAuthUser()?.uid {
                    messagesManager.sendMessage(senderId: user, receiverId: receiverId, message: message)
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
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color("Gray"))
        .cornerRadius(50)
        .padding()
    }
}


