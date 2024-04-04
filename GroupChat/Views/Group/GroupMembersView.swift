//
//  GroupMembersView.swift
//  GroupChat
//
//  Created by Irtaza Fiaz on 02/04/2024.
//

import SwiftUI

struct GroupMembersView: View {
    
    @Binding var members: [UserDetails]
    
    var body: some View {
        
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                
                Text("Members")
                    .font(.custom(FontFamily.bold.rawValue, size: 30))
                    .foregroundStyle(.black)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10)
                
                ForEach(members, id: \.id) { member in
                    HStack {
                        if let url = URL(string: member.photoURL) {
                            AsyncImage(url: url, content: view)
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 30, height: 30)
                                .clipShape(Circle())
                        } else {
                            Color.black
                                .frame(width: 30, height: 30)
                        }
                        
                        Text(member.displayName)
                            .font(.custom(FontFamily.semiBold.rawValue, size: 20))
                            .foregroundStyle(.black)
                            .bold()
                        
                        Spacer()
                        
                    }
                }
                .padding(.top, 20)
            }
            .padding()
        }
        
    }
    
    @ViewBuilder
    private func view(for phase: AsyncImagePhase) -> some View {
        switch phase {
        case .empty:
            ProgressView()
        case .success(let image):
            image
                .resizable()
        case .failure(let error):
            VStack(spacing: 16) {
                Image(systemName: "xmark.octagon.fill")
                    .foregroundColor(.red)
                Text(error.localizedDescription)
                    .multilineTextAlignment(.center)
            }
        @unknown default:
            Text("Unknown")
                .foregroundColor(.gray)
        }
    }
    
}

