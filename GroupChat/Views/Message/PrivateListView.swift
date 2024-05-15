//
//  PrivateListView.swift
//  GroupChat
//
//  Created by Irtaza Fiaz on 06/04/2024.
//

import SwiftUI

struct PrivateListView: View {
    
    // MARK: Data Members
    @State private var selectedMember: UserDetails?
    @State private var openPrivateChat: Bool = false
    
    // MARK: Data Binding
    @StateObject var viewModel: PrivateVM = PrivateVM()
    @EnvironmentObject var sessionManager: SessionManager
    
    // MARK: Body
    var body: some View {
        VStack {
            
            HStack {
                Text("Private Chat")
                    .font(.custom(FontFamily.bold.rawValue, size: 30))
                    .foregroundColor(.white)
                Spacer()
            }
            .frame(height: 30)
            .padding()
            .background(.pink)

            if self.viewModel.members.count > 0 {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(viewModel.members, id: \.id) { member in
                            Button {
                                selectedMember = member
                                self.openPrivateChat.toggle()
                            } label: {
                                VStack(spacing: 0) {
                                    HStack {
                                        if let url = URL(string: member.photoURL) {
                                            CachedAsyncImageView(url: url)
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 30, height: 30)
                                                .clipShape(Circle())
                                        } else {
                                            Color.white
                                                .frame(width: 30, height: 30)
                                        }
                                        
                                        VStack(alignment: .leading) {
                                            Text(member.displayName.uppercased())
                                                .font(.custom(FontFamily.bold.rawValue, size: 20))
                                                .foregroundStyle(.white)
                                                .bold()
                                        }
                                        .padding(.leading, 5)
                                        Spacer()
                                    }
                                    .padding(10)
                                    Divider()
                                        .frame(maxWidth: .infinity)
                                        .background(.white)
                                }
                                
                                
                            }
                        }
                        .background(Color("app-background"))
                    }
                    .background(Color("app-background"))
                }
                .background(Color("app-background"))
            }
            Spacer()
            
        }
        .background(Color("app-background"))
        .onAppear {
            viewModel.startOrRetrieveChat(senderId: sessionManager.getCurrentAuthUser()?.uid ?? "NaN")
        }
        .navigationDestination(isPresented: $openPrivateChat, destination: {
            if let memberId = selectedMember?.id {
                PrivateChatView(receiverId: memberId)
            }
        })
    }
    
}

#Preview {
    PrivateListView(viewModel: PrivateVM())
        .environmentObject(SessionManager())
}

