//
//  QuizDetailView.swift
//  EgenBoys
//
//  Created by 이건준 on 8/11/25.
//

import SwiftUI

struct QuizDetailView: View {
    let item: QuizItem
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let imageURL = item.imageURL {
                    AsyncImage(url: imageURL) { image in
                        image.resizable()
                            .scaledToFill()
                            .frame(width: UIScreen.main.bounds.width - 40, height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .shadow(radius: 10)
                    } placeholder: {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            .scaleEffect(1.5)
                    }
                    .padding(.horizontal)
                }
                
                Text(item.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.horizontal)
                    .lineLimit(.max)
                    .multilineTextAlignment(.center)
                
                Text(item.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .lineLimit(.max)
                
                Text(item.category.rawValue)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(item.category == .all ? Color.blue : Color.green)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    .padding(.top, 10)
                
                if let videoURL = item.videoURL {
                    Link("Watch Video", destination: videoURL)
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 1))
                        .padding(.top, 10)
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 40)
        }
        .navigationBarTitle("퀴즈 상세", displayMode: .inline)
    }
}

