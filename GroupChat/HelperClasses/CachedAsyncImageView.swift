//
//  CachedAsyncImageView.swift
//  GroupChat
//
//  Created by Irtaza Fiaz on 16/04/2024.
//

//import Foundation
//import SwiftUI
//import Combine
//
//struct CachedAsyncImageView: View {
//    let url: URL
//    @State private var image: UIImage? = nil
//    
//    var body: some View {
//        Group {
//            if let image = image {
//                Image(uiImage: image)
//                    .resizable()
//            } else {
//                ProgressView()
//                    .onAppear {
//                        ImageCache.shared.loadImage(url: url) { fetchedImage in
//                            self.image = fetchedImage
//                        }
//                    }
//            }
//        }
//    }
//}
