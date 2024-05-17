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
    var reportAction: () -> Void
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
        HStack {
            if isCurrentUser {
                Spacer()
            }
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 5) {
                
                Text(message.message)
                    .font(.custom(FontFamily.medium.rawValue, size: 18))
                    .foregroundColor(isCurrentUser ? .white : .black)
                    .padding()
                    .background(RoundedCorners(
                        tl: isCurrentUser ? 20 : 8,
                        tr: 20,
                        bl: 20,
                        br: isCurrentUser ? 8 : 20
                    ).fill(
                        isCurrentUser ?
                        Color("primary-color") : Color(hex: "#F5F5F5")
                    ))
                    .contextMenu {
                        Button(action: {
                            reportAction()
                        }) {
                            Text("Report")
                            Image(systemName: "exclamationmark.triangle")
                        }
                    }
                
                Text("\(message.timestamp, formatter: messageDateFormatter)")
                    .font(.caption)
                    .foregroundStyle(.white)

            }
            
            if !isCurrentUser {
                Spacer()
            }
        }
        .padding(isCurrentUser ? .leading : .trailing, 40)
        .transition(.scale)
    }
    
}

#Preview {
    MessageBubble(message: Message(message: "Hello", receiverId: "", senderId: "", timestamp: Date()), reportAction: {}).environmentObject(SessionManager())
}
