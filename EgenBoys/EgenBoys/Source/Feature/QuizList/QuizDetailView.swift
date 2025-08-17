//
//  QuizDetailView.swift
//  EgenBoys
//
//  Created by 이건준 on 8/11/25.
//

import SwiftUI

struct QuizDetailView: View {
    let item: Quiz

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 썸네일
                Group {
                    if let imageURL = item.imageURL {
                        AsyncImage(url: imageURL) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                    .scaleEffect(1.5)
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

                // 제목 / 설명 / 카테고리
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
                    .padding(.top, 4)

                // Watch Video (있을 때만)
                if let videoURL = item.videoURL {
                    Link("Watch Video", destination: videoURL)
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue, lineWidth: 1)
                        )
                        .padding(.horizontal)
                        .padding(.top, 6)
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 40)
        }
        .navigationBarTitle("퀴즈 상세", displayMode: .inline)
    }

    // 플레이스홀더 이미지 (오타 수정 완료)
    private var placeholderImage: some View {
        Image(systemName: "photo")
            .resizable()
            .scaledToFit()
            .frame(width: UIScreen.main.bounds.width - 40, height: 200)
            .foregroundColor(.gray.opacity(0.5))
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.gray.opacity(0.2))   // ✅ 여기!
            )
            .shadow(radius: 10)
    }
}

