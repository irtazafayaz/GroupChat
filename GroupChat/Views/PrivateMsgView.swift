//
//  PrivateMsgView.swift
//  GroupChat
//
//  Created by Irtaza Fiaz on 21/03/2024.
//

//import SwiftUI
//
//struct PrivateMsgView: View {
//    
//    @StateObject var messagesManager = MessagesManager()
//    
//    var body: some View {
//        VStack {
//            VStack {
//                TitleRow()
//                
//                ScrollViewReader { proxy in
//                    ScrollView {
//                        ForEach(messagesManager.messages, id: \.id) { message in
//                            MessageBubble(message: message)
//                        }
//                    }
//                    .padding(.top, 10)
//                    .background(.white)
//                    .cornerRadius(30, corners: [.topLeft, .topRight])
//                    .onChange(of: messagesManager.lastMessageId) {
//                        withAnimation {
//                            proxy.scrollTo(messagesManager.lastMessageId, anchor: .bottom)
//                        }
//                    }
//                }
//            }
//            .background(Color("primary-color"))
//            
//            MessageField()
//                .environmentObject(messagesManager)
//        }
//    }
//}
//
//#Preview {
//    PrivateMsgView()
//}
