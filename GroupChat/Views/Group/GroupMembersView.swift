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
    
    private func isCurrentUser(_ friend: String) -> Bool {
        sessionManager.getCurrentAuthUser()?.uid == friend
    }
    
    var body: some View {
        
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                
                VStack {
                    Text("Members")
                        .font(.custom(FontFamily.bold.rawValue, size: 30))
                        .foregroundStyle(.white)
                        .padding(.top, 15)
                        .padding(.bottom, 5)
                        .frame(maxWidth: .infinity)
                }
                .background(Color("primary-color"))
                .frame(maxWidth: .infinity)
                .ignoresSafeArea(.all)
                
                ForEach(groupchatManager.members, id: \.id) { member in
                    HStack {
                        if let url = URL(string: member.photoURL) {
                            CachedAsyncImageView(url: url)
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 30, height: 30)
                                .clipShape(Circle())
                        } else {
                            Color.black
                                .frame(width: 30, height: 30)
                        }
                        
                        Text(member.displayName.uppercased())
                            .font(.custom(FontFamily.semiBold.rawValue, size: 18))
                            .foregroundStyle(.black)
                            .bold()
                            .padding(.leading, 5)
                        
                        Spacer()
                        
                        Button {
                            if let current = sessionManager.getCurrentAuthUser()?.uid, let friend = member.id {
                                groupchatManager.addFriend(currentUserId: current, friendId: friend)
                            }
                        } label: {
                            Image(systemName: "plus")
                                .font(.custom(FontFamily.regular.rawValue, size: 12))
                                .foregroundColor(.white)
                                .padding(5)
                                .background(!isCurrentUser(member.id ?? "NaN") ? Color("primary-color") : .gray)
                                .cornerRadius(5)
                        }
                        .disabled(isCurrentUser(member.id ?? "NaN"))
                        
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 20)
            }
        }
        .ignoresSafeArea(.all)
        
    }
    
    
    
}

