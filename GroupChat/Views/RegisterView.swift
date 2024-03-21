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
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Sign Up")
                .font(.largeTitle).bold()
            
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
                sessionManager.register(email: email, password: password)
            }
            .foregroundColor(.white)
            .padding()
            .background(Color("Peach"))
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
    }
}


#Preview {
    RegisterView()
}
