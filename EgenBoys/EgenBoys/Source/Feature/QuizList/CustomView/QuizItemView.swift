//
//  QuizItemView.swift
//  EgenBoys
//
//  Created by 이건준 on 8/11/25.
//

import SwiftUI

struct QuizItemView: View {
    let item: Quiz
    
    var body: some View {
        HStack(spacing: 12) {
            Group {
                if let imageURL = item.imageURL {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                .scaleEffect(1.5)
                                .frame(width: 80, height: 80)
                        case .success(let image):
                            image.resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .shadow(radius: 5)
                        case .failure(_):
                            placeholderImage
                        @unknown default:
                            placeholderImage
                        }
                    }
                    .frame(width: 80, height: 80)
                } else {
                    placeholderImage
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Text(item.explanation)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
    }
    
    private var placeholderImage: some View {
        Image(systemName: "photo")
            .resizable()
            .scaledToFit()
            .frame(width: 80, height: 80)
            .foregroundColor(.gray.opacity(0.5))
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.gray.opacity(0.2))
            )
            .shadow(radius: 5)
    }
}
