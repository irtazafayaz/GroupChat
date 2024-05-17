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
    @State private var showDeleteConfirmation: Bool = false
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""
    @State private var showTerms = false
    @State private var showPrivacy = false
    
    var body: some View {
        VStack {
            
            ProfileHeader(imageUrl: $sessionManager.userProfileImageUrl)
            
            Text(sessionManager.userName.uppercased())
                .font(.custom(FontFamily.bold.rawValue, size: 30))
                .foregroundStyle(.white)
                .padding(.top, 10)

            Text(sessionManager.userEmail.lowercased())
                .font(.custom(FontFamily.regular.rawValue, size: 16))
                .foregroundStyle(.white)

            Divider()
                .background(.white)
            
            Button {
                openImagePicker.toggle()
            } label: {
                Text("Change Profile Picture")
                    .font(.custom(FontFamily.bold.rawValue, size: 20))
                    .foregroundStyle(.white)
            }
            .sheet(isPresented: $openImagePicker) {
                ImagePicker(image: $image, isShown: $openImagePicker) {
                    guard let img = image else { return }
                    sessionManager.updateUserProfilePicture(newPhoto: img, completion: {_,_ in })
                }
            }

            
            Divider()
                .background(.white)

            HStack {
                Button {
                    showTerms.toggle()
                } label: {
                    HStack(alignment: .center) {
                        Image("ic_help_center")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 17, height: 20)
                        Text("Terms&Conditions")
                            .font(Font.custom(FontFamily.bold.rawValue, size: 18))
                            .foregroundColor(.white)
                            .padding(.leading, 5)
                        Spacer()
                        Image("ic_arrow_right")
                            .foregroundColor(.black)
                    }
                }
                
                Button {
                    showPrivacy.toggle()
                } label: {
                    HStack(alignment: .center) {
                        Image("ic_privacy_policy")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 17, height: 20)
                        Text("Privacy Policy")
                            .font(Font.custom(FontFamily.bold.rawValue, size: 18))
                            .foregroundColor(.white)
                            .padding(.leading, 5)
                        Spacer()
                        Image("ic_arrow_right")
                            .foregroundColor(.black)
                    }
                }

            }
            
            Divider()
                .background(.white)
            
            Text("Friends")
                .font(.custom(FontFamily.bold.rawValue, size: 24))
                .foregroundStyle(.white)
                .padding(.top)

            VStack(spacing: 0) {
                ForEach(sessionManager.userFriends, id: \.id) { friend in
                    HStack {
                        if let url = URL(string: friend.photoURL) {
                            CachedAsyncImageView(url: url)
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 20, height: 20)
                                .clipShape(Circle())
                                .padding(.leading)
                        } else {
                            Color.white
                                .frame(width: 20, height: 20)
                                .padding(.leading)
                        }
                        
                        Text(friend.displayName.uppercased())
                            .font(.custom(FontFamily.semiBold.rawValue, size: 18))
                            .foregroundStyle(.white)
                            .bold()
                            .padding(.leading, 5)
                        
                        Spacer()
                        
                        Button {
                            selectedFriend = friend.id
                            openChat.toggle()
                        } label: {
                            Image(systemName: "message.fill")
                                .font(.custom(FontFamily.semiBold.rawValue, size: 16))
                                .foregroundColor(.pink)
                                .padding(.trailing)
                        }
                    }
                    .padding(.bottom, 10)
                }
            }
            
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
            
            Button("Delete Account") {
                showDeleteConfirmation = true
            }
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(.red)
            .cornerRadius(10)
            .padding(.bottom, 20)
            .alert("Are you sure you want to delete your account?", isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    sessionManager.deleteAccount { result in
                        switch result {
                        case .success:
                            // Handle successful account deletion if needed
                            break
                        case .failure(let error):
                            errorMessage = error.localizedDescription
                            showErrorAlert = true
                        }
                    }
                }
            }
            
        }
        .sheet(isPresented: $showTerms, content: {
            SharedWebView(pageType: .terms)
        })
        .sheet(isPresented: $showPrivacy, content: {
            SharedWebView(pageType: .privacy)
        })
        .background(Color("app-background"))
        .navigationDestination(isPresented: $openChat, destination: {
            if let user = selectedFriend {
                PrivateChatView(receiverId: user)
            }
        })
        .alert(isPresented: $showErrorAlert) {
            Alert(
                title: Text("Error"),
                message: Text(errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(SessionManager())
}

