//
//  QuizDetailView.swift
//  EgenBoys
//
//  Created by 이건준 on 8/11/25.
//

import SwiftUI
import SwiftData
import AVKit

struct QuizDetailView: View {
    let item: Quiz
    @State private var showVideo = false
    @State private var goToSession = false

    // 세션용 데이터 1개 생성(이 상세의 퀴즈 한 세트)
    private var sessionQuestions: [QuizQuestion] {
        [
            .init(
                text: item.title,
                options: item.questions.map { $0.content },
                answerIndices: Set(item.questions.enumerated().compactMap { $0.element.isCorrect ? $0.offset : nil })
            )
        ]
    }

    private var questionCount: Int { item.questions.count }
    private var estimatedMinutes: Int { max(1, Int(ceil(Double(questionCount) * 0.5))) } // 대략 1문제 30초 가정

    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 20) {

                    // 헤더 이미지
                    EBImageView(url: item.imageURL)
                        .frame(width: UIScreen.main.bounds.width - 40, height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 6)

                    // 제목
                    Text(item.title)
                        .font(.title).bold()
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    // 태그(카테고리/난이도/문항 수)
                    HStack(spacing: 8) {
                        CapsuleTag(text: item.category.rawValue,
                                   foreground: .white,
                                   background: item.category == .ios ? .blue : item.category == .design ? .purple : item.category == .cs ? .teal : .gray)
                        CapsuleTag(text: item.difficultty.rawValue,
                                   foreground: .white,
                                   background: difficultyColor(item.difficultty))
                        CapsuleTag(text: "문항 \(questionCount)개",
                                   foreground: .primary.opacity(0.9),
                                   background: Color(.systemGray6))
                    }
                    .padding(.horizontal)

                    // 요약/설명 카드
                    VStack(alignment: .leading, spacing: 12) {
                        Text("설명")
                            .font(.headline)
                        Text(item.explanation)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color(.systemBackground)))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(.separator), lineWidth: 0.5))
                    .padding(.horizontal)

                    // 메타 정보 카드
                    VStack(spacing: 0) {
                        InfoRow(title: "카테고리", value: item.category.rawValue, icon: "square.grid.2x2")
                        Divider()
                        InfoRow(title: "난이도", value: item.difficultty.rawValue, icon: "chart.bar.doc.horizontal")
                        Divider()
                        InfoRow(title: "예상 소요", value: "~ \(estimatedMinutes)분", icon: "clock")
                    }
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color(.systemBackground)))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(.separator), lineWidth: 0.5))
                    .padding(.horizontal)

                    // 동영상
                    if let videoURL = item.videoURL {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Label("소개 영상", systemImage: "play.rectangle")
                                    .font(.headline)
                                Spacer()
                                Button(showVideo ? "접기" : "보기") {
                                    withAnimation(.easeInOut(duration: 0.2)) { showVideo.toggle() }
                                }
                            }
                            if showVideo {
                                VideoPlayer(player: AVPlayer(url: videoURL))
                                    .frame(height: 220)
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.systemBackground)))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(.separator), lineWidth: 0.5))
                        .padding(.horizontal)
                    }
                }
                .padding(.top, 20)
            }
            
            NavigationLink("", destination: QuizSessionView(questions: sessionQuestions), isActive: $goToSession)
                .hidden()

            Button {
                goToSession = true
            } label: {
                Text("이 퀴즈 풀기")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(difficultyColor(item.difficultty))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
            .shadow(color: difficultyColor(item.difficultty).opacity(0.25), radius: 10, x: 0, y: 6)
        }
        .navigationBarTitle("퀴즈 상세", displayMode: .inline)
    }

    private func difficultyColor(_ d: Difficulty) -> Color {
        switch d {
        case .easy:   return .green
        case .medium: return .orange
        case .hard:   return .red
        }
    }
}

// MARK: - 작은 서브뷰들

private struct CapsuleTag: View {
    let text: String
    let foreground: Color
    let background: Color
    var body: some View {
        Text(text)
            .font(.caption).bold()
            .padding(.horizontal, 10).padding(.vertical, 6)
            .foregroundColor(foreground)
            .background(Capsule().fill(background))
    }
}

private struct InfoRow: View {
    let title: String
    let value: String
    let icon: String
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 24, height: 24)
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .foregroundColor(.primary)
        }
        .font(.body)
        .frame(maxWidth: .infinity)
        .padding()
    }
}


