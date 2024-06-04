//
//  TermsAndAgreements.swift
//  GroupChat
//
//  Created by Irtaza Fiaz on 01/06/2024.
//

import SwiftUI
import UIKit

struct HTMLStringView: UIViewRepresentable {
    let htmlContent: String

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.backgroundColor = .clear
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        guard let data = htmlContent.data(using: .utf8) else { return }
        
        let attributedString: NSAttributedString
        do {
            attributedString = try NSAttributedString(
                data: data,
                options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue],
                documentAttributes: nil)
        } catch {
            attributedString = NSAttributedString(string: "Failed to load content")
        }
        
        uiView.attributedText = attributedString
    }
}

struct TermsAndAgreements: View {
    @State private var content: String = "<p>Loading...</p>"
    
    var body: some View {
        HTMLStringView(htmlContent: content)
            .onAppear {
                fetchContent()
            }
            .padding()
    }
    
    func fetchContent() {
        guard let url = URL(string: "https://www.termsfeed.com/live/53290490-34c1-458e-aeaa-74709d2c90c9") else {
            content = "<p>Invalid URL</p>"
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    content = "<p>Error: \(error.localizedDescription)</p>"
                }
                return
            }
            
            guard let data = data, let fetchedContent = String(data: data, encoding: .utf8) else {
                DispatchQueue.main.async {
                    content = "<p>Failed to load content</p>"
                }
                return
            }
            
            DispatchQueue.main.async {
                content = fetchedContent
            }
        }.resume()
    }
}

#Preview {
    TermsAndAgreements()
}
