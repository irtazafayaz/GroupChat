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
        VStack(spacing: 16) {
            Text("Sign In")
                .font(.largeTitle).bold()
            
            CustomTextField(placeholder: Text("Email"), text: $email)
                .padding()
                .background(Color("Gray"))
                .cornerRadius(10)
            
            CustomTextField(placeholder: Text("Password"), text: $password)
                .padding()
                .background(Color("Gray"))
                .cornerRadius(10)
            
            Button("Sign In") {
                sessionManager.login(email: email, password: password)
            }
            .foregroundColor(.white)
            .padding()
            .background(Color("primary-color"))
            .cornerRadius(10)
            
            Spacer()
            
            HStack {
                Text("Doesn't have an account?")
                    .font(Font.custom("MontserratAlternates-Regular", size: 16))
                Button(action: { sessionManager.authState = .register }) {
                    Text("Register")
                        .font(Font.custom("MontserratAlternates-Bold", size: 12))
                        .underline()
                }
            }
            .foregroundColor(Color.black)
            .padding(.bottom)
            
        }
        .padding()
    }
}


#Preview {
    LoginView()
}
