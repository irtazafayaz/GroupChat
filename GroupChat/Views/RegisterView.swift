//
//  RegisterView.swift
//  GroupChat
//
//  Created by Irtaza Fiaz on 21/03/2024.
//

import SwiftUI

struct RegisterView: View {
    
    @EnvironmentObject var sessionManager: SessionManager
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var fullName = ""
    @State private var image: UIImage?
    @State private var showImagePicker = false
    
    
    var body: some View {
        ZStack {
            VStack(spacing: 10) {
                Text("Sign Up")
                    .font(.largeTitle).bold()
                
                VStack {
                    if let selectedImage = image {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100, alignment: .center)
                            .clipShape(Circle())
                            .onTapGesture {
                                showImagePicker = true
                            }
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .foregroundColor(.gray)
                            .frame(width: 100, height: 100, alignment: .center)
                            .onTapGesture {
                                showImagePicker = true
                            }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
                
                CustomTextField(label: $fullName, placeholder: "Enter your full name", textfieldType: .normal)
                
                CustomTextField(label: $email, placeholder: "Email", textfieldType: .email)
                
                CustomTextField(label: $password, placeholder: "Password", textfieldType: .password)
                
                CustomTextField(label: $confirmPassword, placeholder: "Confirm Password", textfieldType: .password)
                
                Button("Sign Up") {
                    sessionManager.createNewUser(
                        name: fullName,
                        email: email,
                        photo: image ?? UIImage(systemName: "person.crop.circle.fill"),
                        password: password
                    )
                }
                .foregroundColor(.white)
                .padding()
                .background(Color("primary-color"))
                .cornerRadius(10)
                
                Spacer()
                
                HStack {
                    Text("Already have an account?")
                        .font(Font.system(size: 16))
                    Button(action: { sessionManager.authState = .login }) {
                        Text("SIGN IN")
                            .font(Font.system(size: 16))
                            .underline()
                            .bold()
                    }
                }
                .foregroundColor(Color.black)
                .padding(.bottom)
                
            }
            .padding()
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $image, isShown: $showImagePicker) {}
            }
            .blur(radius: sessionManager.isLoading ? 3 : 0)
            
            
            if sessionManager.isLoading {
                Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                
                ProgressView()
                    .scaleEffect(2)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
            
        }
    }
}


#Preview {
    RegisterView()
}
