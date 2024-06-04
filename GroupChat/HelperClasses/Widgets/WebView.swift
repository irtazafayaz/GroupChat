//
//  WebView.swift
//  AiChatBot
//
//  Created by Irtaza Fiaz on 05/09/2023.
//

import Foundation
import SwiftUI
import UIKit
import WebKit

struct WebView: UIViewRepresentable {
    
    private var loadingObservation: NSKeyValueObservation?

    private let loadingIndicator: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.color = .black
        return spinner
    }()
    
    typealias UIViewType = WKWebView
    
    let webView: WKWebView
    
    init(url: String) {
        webView = WKWebView(frame: .zero)
        webView.load(URLRequest(url: URL(string: url)!))
        webView.addSubview(self.loadingIndicator)
        self.loadingIndicator.startAnimating()
        NSLayoutConstraint.activate([self.loadingIndicator.centerXAnchor.constraint(equalTo: self.webView.centerXAnchor),
                                     self.loadingIndicator.centerYAnchor.constraint(equalTo: self.webView.centerYAnchor)])
        self.webView.bringSubviewToFront(self.loadingIndicator)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        webView
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
        webView.navigationDelegate = context.coordinator
    }
    func makeCoordinator() -> WebCoordinator {
        WebCoordinator(webView, loadingIndicator: loadingIndicator)
        
    }
}

class WebCoordinator: NSObject, WKNavigationDelegate {
    var parent: WKWebView
    var loadingIndicator: UIActivityIndicatorView
    
    init(_ parent: WKWebView, loadingIndicator: UIActivityIndicatorView) {
        self.parent = parent
        self.loadingIndicator = loadingIndicator
    }
    
    // Delegate methods go here
    
    func webView(_ webView: WKWebView,didFinish navigation: WKNavigation!) {
        self.loadingIndicator.stopAnimating()
        self.loadingIndicator.removeFromSuperview()
        
    }

}
