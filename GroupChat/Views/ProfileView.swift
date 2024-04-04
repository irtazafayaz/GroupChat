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

    var body: some View {
        VStack {
            
            TitleRow(imageUrl: sessionManager.userProfileImageUrl, name: sessionManager.userName)
            
            Button("Sign Out") {
                sessionManager.logout()
            }
            .foregroundColor(.white)
            .padding()
            .background(Color("primary-color"))
            .cornerRadius(10)
            
            Spacer()
        }
        .padding()
    }
}


#Preview {
    ProfileView()
}
