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
    @State private var agreedTermsAndConditions = false
    @State private var showTermsAndConditions = false
    @State private var termsContent: String = "<p>Loading...</p>"
    @State private var showAlert: Bool = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 10) {
                Text("Sign Up")
                    .foregroundStyle(.white)
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
                
                HStack {
                    Text("I accept the")
                        .font(.system(size: 16))
                    
                    Button(action: {
                        if termsContent == "<p>Loading...</p>" {
                            fetchTermsContent()
                        } else {
                            showTermsAndConditions.toggle()
                        }
                    }) {
                        Text("terms and conditions")
                            .font(.system(size: 16))
                            .underline()
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Toggle("", isOn: $agreedTermsAndConditions)
                        .labelsHidden()
                        .tint(.black)
                }
                .foregroundColor(.white)
                .padding(.bottom)
                .padding(.horizontal)
                
                
                Button("Sign Up") {
                    if agreedTermsAndConditions {
                        sessionManager.createNewUser(
                            name: fullName,
                            email: email,
                            photo: image ?? UIImage(systemName: "person.crop.circle.fill"),
                            password: password
                        )
                    } else {
                        showAlert.toggle()
                    }
                    
                }
                .foregroundColor(.white)
                .padding()
                .background(.black)
                .cornerRadius(10)
                .alert("You need to agree to the terms and conditions", isPresented: $showAlert, actions: {})
                
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
                .foregroundColor(.white)
                .padding(.bottom)
                
            }
            .padding()
            .background(Color("app-background"))
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $image, isShown: $showImagePicker) {}
            }
            .sheet(isPresented: $showTermsAndConditions, content: {
                TermsAndAgreements(content: $termsContent)
            })
            .blur(radius: sessionManager.isLoading ? 3 : 0)
            
            
            if sessionManager.isLoading {
                Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                
                ProgressView()
                    .scaleEffect(2)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
            
        }
    }
    
    func fetchTermsContent() {
        guard let url = URL(string: "https://www.termsfeed.com/live/53290490-34c1-458e-aeaa-74709d2c90c9") else {
            termsContent = "<p>Invalid URL</p>"
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    termsContent = "<p>Error: \(error.localizedDescription)</p>"
                }
                return
            }
            
            guard let data = data, let fetchedContent = String(data: data, encoding: .utf8) else {
                DispatchQueue.main.async {
                    termsContent = "<p>Failed to load content</p>"
                }
                return
            }
            
            DispatchQueue.main.async {
                termsContent = fetchedContent
                showTermsAndConditions.toggle()
            }
        }.resume()
    }
    
}


#Preview {
    RegisterView()
        .environmentObject(SessionManager())
}
