//
//  ProfileView.swift
//  GroupChat
//
//  Created by Irtaza Fiaz on 21/03/2024.
//

import SwiftUI

struct ProfileView: View {
    
    @EnvironmentObject var sessionManager: SessionManager
    @State private var openImagePicker: Bool = false
    @State private var openChat: Bool = false
    @State private var isFriendsListExpanded: Bool = false
    @State private var image: UIImage?
    @State private var selectedFriend: String?

    var body: some View {
        VStack {
            
            ProfileHeader(imageUrl: sessionManager.userProfileImageUrl)
            
            Text(sessionManager.userName.uppercased())
                .font(.custom(FontFamily.bold.rawValue, size: 30))
                .foregroundStyle(.black)
                .padding(.top, 10)

            Text(sessionManager.userEmail.lowercased())
                .font(.custom(FontFamily.regular.rawValue, size: 16))
                .foregroundStyle(.gray)

            Divider()
            
            DisclosureGroup(isExpanded: $isFriendsListExpanded) {
                VStack {
                    ForEach(sessionManager.userFriends, id: \.id) { friend in
                        HStack {
                            Text(friend.displayName.uppercased())
                                .font(.custom(FontFamily.semiBold.rawValue, size: 20))
                                .foregroundColor(.black)
                            Spacer()
                            Button {
                                selectedFriend = friend.id
                                openChat.toggle()
                            } label: {
                                Image(systemName: "message.fill")
                                    .font(.custom(FontFamily.semiBold.rawValue, size: 16))
                                    .foregroundColor(Color("primary-color"))
                            }
                        }
                        
                    }
                }
                .padding(.top)
            } label: {
                HStack {
                    Text("Friends")
                        .font(.custom(FontFamily.bold.rawValue, size: 24))
                        .foregroundColor(.black)
                    Spacer()
                }
                .onTapGesture {
                    isFriendsListExpanded.toggle()
                }
            }
            .tint(.clear)
            .padding()
            
            Spacer()
            
            Button("Sign Out") {
                sessionManager.logout()
            }
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(.red)
            .cornerRadius(10)
            .padding(.bottom, 20)
            
        }
        .onAppear {
            sessionManager.fetchUserFriends()
        }
        .navigationDestination(isPresented: $openChat, destination: {
            if let user = selectedFriend {
                PrivateChatView(receiverId: user)
            }
        })
    }
}


#Preview {
    ProfileView()
}
