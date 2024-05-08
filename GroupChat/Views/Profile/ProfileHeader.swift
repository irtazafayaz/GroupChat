//
//  ProfileHeader.swift
//  GroupChat
//
//  Created by Irtaza Fiaz on 06/04/2024.
//

import SwiftUI

struct ProfileHeader: View {
    
    @Binding var imageUrl: URL?
    
    var body: some View {
        ZStack(alignment: .top) {
            
            Rectangle()
                .foregroundColor(Color("primary-color"))
                .edgesIgnoringSafeArea(.top)
                .frame(height: 70)
            
            if let url = imageUrl {   
                CachedAsyncImageView(url: url)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .shadow(radius: 10)
                    .padding(.top, 20)
            } else {
                Color.white
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .shadow(radius: 10)
                    .padding(.top, 20)
            }
            
            
        }
        .frame(maxWidth: .infinity)
    }
}

