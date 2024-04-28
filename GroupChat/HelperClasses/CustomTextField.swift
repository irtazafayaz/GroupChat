//
//  CustomTextField.swift
//  GroupChat
//
//  Created by Irtaza Fiaz on 29/04/2024.
//

import SwiftUI

enum TextFieldType {
    case email
    case password
    case normal
}

struct CustomTextField: View {
    
    @Binding var label: String
    @State private var isVisible: Bool = false
    var placeholder: String = "Enter here..."
    var textfieldType: TextFieldType
    
    var body: some View {
        HStack {
            if textfieldType != .normal {
                Image(systemName: textfieldType == .email ? "envelope" : "lock")
                    .foregroundColor(.gray)
            }
            if textfieldType == .email || textfieldType == .normal || isVisible {
                TextField(placeholder, text: $label)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(12)
            } else {
                SecureField(placeholder, text: $label)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(12)
            }
            if textfieldType == .password {
                Button(action: {
                    self.isVisible.toggle()
                }) {
                    Image(systemName: self.isVisible ? "eye.slash" : "eye")
                        .foregroundColor(.gray)
                }
            }
            
        }
        .padding(.horizontal)
        .background(RoundedRectangle(cornerRadius: 10).fill(.gray.opacity(0.3)))
        .padding()
    }
}
