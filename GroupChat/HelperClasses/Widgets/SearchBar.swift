//
//  SearchBar.swift
//  GroupChat
//
//  Created by Irtaza Fiaz on 04/04/2024.
//

import Foundation
import SwiftUI

struct SearchBar: View {
    
    @Binding var text: String
    
    var body: some View {
        HStack {
        
            TextField("Search", text: $text)
                .padding(7).padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 10)
            
        }.padding(.top, 10)
    }
}
