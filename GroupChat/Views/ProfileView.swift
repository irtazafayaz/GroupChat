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
    @State private var image: UIImage?
    @State private var isFriendsListExpanded: Bool = false

    var body: some View {
        VStack {
            
            TitleRow(imageUrl: sessionManager.userProfileImageUrl, name: sessionManager.userName)

            DisclosureGroup(isExpanded: $isFriendsListExpanded) {
                VStack {
                    ForEach(sessionManager.userFriends, id: \.id) { friend in
                        HStack {
                            Text(friend.displayName)
                                .foregroundColor(.black)
                            Spacer()
                            Button("Chat") {
                                
                            }
                        }
                        
                    }
                }
            } label: {
                HStack {
                    Text("Friends")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .background(Color("primary-color"))
                        .cornerRadius(10)

                }
                .onTapGesture {
                    isFriendsListExpanded.toggle()
                }
            }
            
            Button("Sign Out") {
                sessionManager.logout()
            }
            .foregroundColor(.white)
            .padding()
            .background(.red)
            .cornerRadius(10)
            .padding(.top, 30)
            
            Spacer()
        }
        .padding()
        .onAppear {
            sessionManager.fetchUserFriends()
        }
    }
}


#Preview {
    ProfileView()
}
