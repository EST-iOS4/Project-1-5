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
    @State private var showVideo = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // 썸네일
                Group {
                    if let url = item.imageURL {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .frame(width: UIScreen.main.bounds.width - 40, height: 200)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: UIScreen.main.bounds.width - 40, height: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                    .shadow(radius: 10)
                            case .failure:
                                placeholderImage
                            @unknown default:
                                placeholderImage
                            }
                        }
                        .frame(width: UIScreen.main.bounds.width - 40, height: 200)
                    } else {
                        placeholderImage
                    }
                }

                // 제목 / 설명
                Text(item.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)

                Text(item.explanation)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .multilineTextAlignment(.leading)

                // 카테고리 배지
                Text(item.category.rawValue)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(item.category == .all ? Color.blue : Color.green)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)

                // 동영상 보기 (URL 있을 때만)
                if let videoURL = item.videoURL {
                    Button {
                        withAnimation { showVideo.toggle() }
                    } label: {
                        Text(showVideo ? "동영상 닫기" : "동영상 보기")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.blue, lineWidth: 1)
                            )
                    }
                    .padding(.horizontal)

                    if showVideo {
                        VideoPlayer(player: AVPlayer(url: videoURL))
                            .frame(height: 220)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .padding(.horizontal)
                    }
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 40)
        }
        .navigationBarTitle("퀴즈 상세", displayMode: .inline)
    }

    // 플레이스홀더 이미지
    private var placeholderImage: some View {
        Image(systemName: "photo")
            .resizable()
            .scaledToFit()
            .frame(width: UIScreen.main.bounds.width - 40, height: 200)
            .foregroundColor(.gray.opacity(0.5))
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.gray.opacity(0.2))
            )
            .shadow(radius: 10)
    }
}

