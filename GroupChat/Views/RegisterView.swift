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
        VStack(spacing: 16) {
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
            
            CustomTextField(placeholder: Text("Name"), text: $fullName)
                .padding()
                .background(Color("Gray"))
                .cornerRadius(10)
            
            CustomTextField(placeholder: Text("Email"), text: $email)
                .padding()
                .background(Color("Gray"))
                .cornerRadius(10)
            
            CustomTextField(placeholder: Text("Password"), text: $password)
                .padding()
                .background(Color("Gray"))
                .cornerRadius(10)
            
            CustomTextField(placeholder: Text("Confirm Password"), text: $confirmPassword)
                .padding()
                .background(Color("Gray"))
                .cornerRadius(10)
            
            Button("Sign Up") {
                sessionManager.createNewUser(name: fullName, email: email, photo: image, password: password)
            }
            .foregroundColor(.white)
            .padding()
            .background(Color("primary-color"))
            .cornerRadius(10)
            
            Spacer()
            
            HStack {
                Text("Already have an account?")
                    .font(Font.custom("MontserratAlternates-Regular", size: 16))
                Button(action: { sessionManager.authState = .login }) {
                    Text("SIGN IN")
                        .font(Font.custom("MontserratAlternates-Bold", size: 12))
                        .underline()
                }
            }
            .foregroundColor(Color.black)
            .padding(.bottom)
            
        }
        .padding()
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $image, isShown: $showImagePicker) {
            }
        }
    }
}


#Preview {
    RegisterView()
}
