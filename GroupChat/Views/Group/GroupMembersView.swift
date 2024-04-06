//
//  GroupMembersView.swift
//  GroupChat
//
//  Created by Irtaza Fiaz on 02/04/2024.
//

import SwiftUI

struct GroupMembersView: View {
    
    @EnvironmentObject var groupchatManager: GroupChatVM
    @EnvironmentObject var sessionManager: SessionManager
    
    var body: some View {
        
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                
                VStack {
                    Text("Members")
                        .font(.custom(FontFamily.bold.rawValue, size: 30))
                        .foregroundStyle(.white)
                        .padding(.top, 15)
                        .frame(maxWidth: .infinity)
                }
                .background(Color("primary-color"))
                .frame(maxWidth: .infinity)
                .ignoresSafeArea(.all)
                
                ForEach(groupchatManager.members, id: \.id) { member in
                    HStack {
                        if let url = URL(string: member.photoURL) {
                            AsyncImage(url: url, content: view)
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 20, height: 20)
                                .clipShape(Circle())
                        } else {
                            Color.black
                                .frame(width: 20, height: 20)
                        }
                        
                        Text(member.displayName.uppercased())
                            .font(.custom(FontFamily.semiBold.rawValue, size: 20))
                            .foregroundStyle(.black)
                            .bold()
                        
                        Spacer()
                        
                        Button {
                            if let current = sessionManager.getCurrentAuthUser()?.uid, let friend = member.id {
                                groupchatManager.addFriend(currentUserId: current, friendId: friend)
                            }
                        } label: {
                            HStack {
                                Image(systemName: "plus")
                            }
                            .foregroundColor(.white)
                            .padding(5)
                            .background(Color("primary-color"))
                            .cornerRadius(10)
                        }
                        
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 20)
            }
        }
        .ignoresSafeArea(.all)
        
        
    }
    
    @ViewBuilder
    private func view(for phase: AsyncImagePhase) -> some View {
        switch phase {
        case .empty:
            ProgressView()
        case .success(let image):
            image
                .resizable()
        case .failure(let error):
            VStack(spacing: 16) {
                Image(systemName: "xmark.octagon.fill")
                    .foregroundColor(.red)
                Text(error.localizedDescription)
                    .multilineTextAlignment(.center)
            }
        @unknown default:
            Text("Unknown")
                .foregroundColor(.gray)
        }
    }
    
}

