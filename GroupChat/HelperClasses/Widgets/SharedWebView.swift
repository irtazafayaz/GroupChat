//
//  SharedWebView.swift
//  AiChatBot
//
//  Created by Irtaza Fiaz on 05/09/2023.
//

import SwiftUI
import UIKit
import WebKit

enum PageType {
    case terms
    case privacy
}

struct SharedWebView: View {
    let pageType: PageType
    var body: some View {
        VStack(alignment: .center) {
            WebView(url: (
                pageType == .privacy
                ? "https://www.freeprivacypolicy.com/live/b406c6b9-9740-41ad-986e-83b216cccc3e"
                : "https://www.termsfeed.com/live/53290490-34c1-458e-aeaa-74709d2c90c9"
            ))
            Spacer()
        }
    }
}

struct Previews_SharedWebView_Previews: PreviewProvider {
    static var previews: some View {
        SharedWebView(pageType: .terms)
    }
}

