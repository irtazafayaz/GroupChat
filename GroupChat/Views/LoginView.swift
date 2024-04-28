//
//  LoginView.swift
//  GroupChat
//
//  Created by Irtaza Fiaz on 21/03/2024.
//

import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject var sessionManager: SessionManager
    
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        ZStack {
            VStack(spacing: 10) {
                Spacer()

                Image(systemName: "message.badge.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundStyle(Color("primary-color"))
                
                Text("Anonymous Chat Group")
                    .font(.largeTitle).bold()
                    .padding(.bottom, 40)
                
                CustomTextField(label: $email, textfieldType: .email)
                CustomTextField(label: $password, textfieldType: .password)

                Button {
                    sessionManager.login(email: email, password: password)
                } label: {
                    Text("Login")
                        .frame(width: 200)
                        .foregroundColor(.white)
                        .padding(.vertical, 15)
                        .background(Color("primary-color"))
                        .cornerRadius(10)
                }

                Spacer()
                
                HStack {
                    Text("Don't have an account?")
                        .font(Font.system(size: 16))
                    Button(action: { sessionManager.authState = .register }) {
                        Text("Register")
                            .font(Font.system(size: 16))
                            .bold()
                            .underline()
                    }
                }
                .foregroundColor(Color.black)
                .padding(.bottom)
            }
            .padding()
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
    LoginView().environmentObject(SessionManager())
}
