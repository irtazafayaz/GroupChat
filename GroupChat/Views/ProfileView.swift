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
            
            Button {
                openImagePicker.toggle()
            } label: {
                HStack(alignment: .center) {
                    Image("ic_help_center")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 17, height: 20)
                    Text("Change Profile Picture")
                        .font(Font.custom(FontFamily.bold.rawValue, size: 18))
                        .foregroundColor(Color(hex: Colors.labelDark.rawValue))
                        .padding(.leading, 5)
                    Spacer()
                    Image("ic_arrow_right")
                        .foregroundColor(.black)
                }
                .padding(.top, 20)
            }
            .sheet(isPresented: $openImagePicker) {
                ImagePicker(image: $image, isShown: $openImagePicker) {
                    
                }
            }
            
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
