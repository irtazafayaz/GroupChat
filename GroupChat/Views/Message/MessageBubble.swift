//
//  ContentView.swift
//  GroupChat
//
//  Created by Irtaza Fiaz on 21/03/2024.
//

import SwiftUI

struct MessageBubble: View {
    @EnvironmentObject var sessionManager: SessionManager

    var message: Message
    @State private var showTime = false
    
    private var isCurrentUser: Bool {
        sessionManager.getCurrentAuthUser()?.uid == message.senderId
    }
    
    private var messageDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        VStack(alignment: isCurrentUser ? .leading : .trailing) {
            HStack {
                Text(message.message)
                    .padding()
                    .background(isCurrentUser ? Color("Gray") : Color("primary-color"))
                    .cornerRadius(30)
            }
            .frame(maxWidth: 300, alignment: isCurrentUser ? .leading : .trailing)
            .onTapGesture {
                showTime.toggle()
            }
            
            if showTime {
                Text("\(message.timestamp.formatted(.dateTime.hour().minute()))")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(isCurrentUser ? .leading : .trailing, 25)
            }
        }
        .frame(maxWidth: .infinity, alignment: isCurrentUser ? .leading : .trailing)
        .padding(isCurrentUser ? .leading : .trailing)
        .padding(.horizontal, 10)
    }
}

