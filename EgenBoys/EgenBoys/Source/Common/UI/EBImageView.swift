//
//  EBImageView.swift
//  EgenBoys
//
//  Created by 이건준 on 8/13/25.
//

import SwiftUI

struct EBImageView: View {
    @StateObject private var cacheManager = CacheManager()
    @State private var imageOpcity = 0.0
    let url: URL?
    let placeholder: Image
    
    init(url: URL?, placeholder: Image = Image(systemName: "photo"))
    {
        self.url = url
        self.placeholder = placeholder
    }
    
    init(urlString: String, placeholder: Image = Image(systemName: "photo")) {
        self.init(url: URL(string: urlString), placeholder: placeholder)
    }
    
    var body: some View {
        Group {
            if let image = cacheManager.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .opacity(imageOpcity)
                    .onAppear {
                        withAnimation(.default.delay(0.1)) {
                            imageOpcity = 1.0
                        }
                    }
            } else if cacheManager.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(1.5)
            } else {
                placeholderImage
            }
        }
        .onAppear {
            cacheManager.load(from: url)
        }
        .onDisappear {
            cacheManager.cancel()
        }
    }
}

extension EBImageView {
    private var placeholderImage: some View {
        placeholder
            .resizable()
            .scaledToFit()
            .foregroundColor(.gray.opacity(0.5))
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.gray.opacity(0.2))
            )
    }
}
