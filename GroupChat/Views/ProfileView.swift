//
//  ProfileView.swift
//  GroupChat
//
//  Created by Irtaza Fiaz on 21/03/2024.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var sessionManager: SessionManager
    
    var body: some View {
        VStack {
            // Example user profile display
            TitleRow() // Reuse your existing TitleRow for the profile header
            
            Button("Sign Out") {
                sessionManager.logout()
            }
            .foregroundColor(.white)
            .padding()
            .background(Color("Peach"))
            .cornerRadius(10)
            
            Spacer()
        }
        .padding()
    }
}


#Preview {
    ProfileView()
}
