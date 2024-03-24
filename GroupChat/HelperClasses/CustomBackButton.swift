//
//  CustomBackButton.swift
//  GroupChat
//
//  Created by Irtaza Fiaz on 23/03/2024.
//

import Foundation
import SwiftUI

struct CustomBackButton: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.black)
                .font(.title2)
                .padding(.leading)
        }
    }
}
