//
//  GroupMessageBubble.swift
//  GroupChat
//
//  Created by Irtaza Fiaz on 23/03/2024.
//

import SwiftUI

struct GroupMessageBubble: View {
    
    @EnvironmentObject var sessionManager: SessionManager
    private var message: GroupMessage
    
    init(message: GroupMessage) {
        self.message = message
    }
    
    var body: some View {
        HStack {
            if isCurrentUser {
                Spacer()
            }
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 5) {
                
                if !isCurrentUser {
                    Text(message.senderName.components(separatedBy: "@").first ?? message.senderName)
                        .font(.custom(FontFamily.regular.rawValue, size: 12))
                        .foregroundColor(.white)
                        .bold()
                }
                
                Text(message.content)
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
                
                Text("\(message.timestamp, formatter: messageDateFormatter)")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.bottom, 5)
                
            }
            
            if !isCurrentUser {
                Spacer()
            }
        }
        .padding(isCurrentUser ? .leading : .trailing, 40)
        .transition(.scale)
    }
    

    func getMessageViewWithImage(_ message: GroupMessage) -> some View {
        HStack {
            if isCurrentUser {
                Spacer()
            }
            HStack {
                Text(message.content)
                    .font(.custom(FontFamily.medium.rawValue, size: 18))
                    .foregroundColor(isCurrentUser ? .white : .black)
                    .padding()
                    .background(RoundedCorners(
                        tl: isCurrentUser ? 20 : 8,
                        tr: 20,
                        bl: 20,
                        br: isCurrentUser ? 8 : 20
                    ).fill(isCurrentUser ? Color(hex: Colors.primary.rawValue) : Color(hex: "#F5F5F5")))
                
            }
            if !isCurrentUser {
                Spacer()
            }
        }
        .padding(.vertical, 10)
    }
    
    private var isCurrentUser: Bool {
        sessionManager.getCurrentAuthUser()?.uid == message.senderId
    }
    
    private var messageDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
}

