//
//  GroupMessageBubble.swift
//  GroupChat
//
//  Created by Irtaza Fiaz on 23/03/2024.
//

import SwiftUI

struct GroupMessageBubble: View {
 
    @State private var showTime = false
    @EnvironmentObject var sessionManager: SessionManager
    var message: GroupMessage

    var body: some View {
        VStack(alignment: sessionManager.getCurrentAuthUser() == nil ? .leading : .trailing) {
            HStack {
                Text(message.content)
                    .padding()
                    .background(sessionManager.getCurrentAuthUser() == nil ? Color("Gray") : Color("Peach"))
                    .cornerRadius(30)
            }
            .frame(maxWidth: 300, alignment: sessionManager.getCurrentAuthUser() == nil ? .leading : .trailing)
            .onTapGesture {
                showTime.toggle()
            }
            
            if showTime {
                Text("\(message.timestamp.formatted(.dateTime.hour().minute()))")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(sessionManager.getCurrentAuthUser() == nil ? .leading : .trailing, 25)
            }
        }
        .frame(maxWidth: .infinity, alignment: sessionManager.getCurrentAuthUser() == nil ? .leading : .trailing)
        .padding(sessionManager.getCurrentAuthUser() == nil ? .leading : .trailing)
        .padding(.horizontal, 10)
    }
    
}

#Preview {
    GroupMessageBubble(message: GroupMessage(senderId: "11", timestamp: .now, content: ""))
}
