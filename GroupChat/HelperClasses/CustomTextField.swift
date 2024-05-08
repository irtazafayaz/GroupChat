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
                    .foregroundColor(.white)
            }
            if textfieldType == .email || textfieldType == .normal || isVisible {
                TextField("", text: $label)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundStyle(.white)
                    .tint(.white)
                    .placeholder(when: label.isEmpty) {
                        Text(placeholder).foregroundColor(.gray)
                    }
                    .padding(12)
                    
            } else {
                SecureField(placeholder, text: $label)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundStyle(.white)
                    .tint(.white)
                    .placeholder(when: label.isEmpty) {
                        Text(placeholder).foregroundColor(.gray)
                    }
                    .padding(12)
                    
            }
            if textfieldType == .password {
                Button(action: {
                    self.isVisible.toggle()
                }) {
                    Image(systemName: self.isVisible ? "eye.slash" : "eye")
                        .foregroundColor(.white)
                }
            }
            
        }
        .padding(.horizontal)
        .background(RoundedRectangle(cornerRadius: 10).fill(.gray.opacity(0.3)))
        .padding()
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
            
            ZStack(alignment: alignment) {
                placeholder().opacity(shouldShow ? 1 : 0)
                self
            }
        }
}
