//
//  ContentView.swift
//  GroupChat
//
//  Created by Irtaza Fiaz on 21/03/2024.
//

import SwiftUI

struct TitleRow: View {
    
    private var imageUrl: URL?
    private var name: String
    
    init(
        imageUrl: URL? = URL(string: "https://images.unsplash.com/photo-1567532939604-b6b5b0db2604?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8"),
        name: String = "Sarah Smith"
    ) {
        self.imageUrl = imageUrl
        self.name = name
    }
    
    var body: some View {
        HStack(spacing: 10) {
            if let url = imageUrl {
                CachedAsyncImageView(url: url)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .cornerRadius(50)
            }
            VStack(alignment: .leading) {
                Text(name.uppercased())
                    .font(.custom(FontFamily.bold.rawValue, size: 20))
                    .foregroundStyle(.white)

            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
    }
}

struct TitleRow_Previews: PreviewProvider {
    static var previews: some View {
        TitleRow()
            .background(Color("primary-color"))
    }
}
