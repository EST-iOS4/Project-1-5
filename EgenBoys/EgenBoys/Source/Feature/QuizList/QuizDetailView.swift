//
//  QuizDetailView.swift
//  EgenBoys
//
//  Created by 이건준 on 8/11/25.
//

import SwiftUI
import AVKit

struct QuizDetailView: View {
    let item: Quiz
    @State var playingQuizID: UUID?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                EBImageView(url: item.imageURL)
                    .frame(width: UIScreen.main.bounds.width - 40, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(radius: 10)
                
                Text(item.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.horizontal)
                    .lineLimit(.max)
                    .multilineTextAlignment(.center)
                
                Text(item.explanation)
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
                
                Button(action: {
                    playingQuizID = item.id
                }) {
                    Text("동영상 보기")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 1))
                }
                .padding(.horizontal)
                if playingQuizID == item.id {
                    if let videoURL = item.videoURL {
                        VideoPlayer(player: AVPlayer(url: videoURL))
                            .frame(height: 200)
                            .cornerRadius(15)
                            .padding()
                            .onTapGesture {
                                playingQuizID = nil
                            }
                    }
                }
                        
            }
            .padding(.top, 20)
            .padding(.bottom, 40)
        }
        .navigationBarTitle("퀴즈 상세", displayMode: .inline)
    }
}


