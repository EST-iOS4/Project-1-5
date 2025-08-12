//
//  QuizSessionView.swift
//  EgenBoys
//
//  Created by 정수안 on 8/11/25.
//

import SwiftUI

struct QuizSessionView: View {
    // 한 문제만 UI 테스트
    @State private var currentIndex: Int = 0
    private let totalCount: Int = 1

    @State private var questionText: String = "질문"
    @State private var options: [String] = ["@1", "@2", "@3", "@4"]

    // ✅ 정답(복수 가능) 내가 정하는것
    private let answerIndices: Set<Int> = [1, 3]

    // ✅ 복수선택 상태
    @State private var selectedIDs: Set<Int> = []

    @State private var showSummary = false
    @State private var scorePercent = 0  // 제출 시 계산해서 채움 (0~100)

    var body: some View {
        VStack(spacing: 16) {
            // 상단 진행도
            VStack(spacing: 6) {
                ProgressView(value: Double(currentIndex+1), total: Double(totalCount))
                    .tint(.blue)
                    .padding(.horizontal)
                Text("\(currentIndex+1) / \(totalCount)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 6)

            ScrollView {
                VStack(spacing: 16) {
                    SectionCard("문제") {
                        Text(questionText)
                            .font(.title3.bold())
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    SectionCard("보기") {
                        VStack(spacing: 10) {
                            ForEach(options.indices, id: \.self) { i in
                                CheckboxRow(
                                    index: i+1,
                                    text: options[i],
                                    isSelected: selectedIDs.contains(i)
                                )
                                .onTapGesture {
                                    if selectedIDs.contains(i) {
                                        selectedIDs.remove(i)
                                    } else {
                                        selectedIDs.insert(i)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
            }

            // 하단 버튼
            Button {
                // ✅ 부분 점수 계산 → 0~100 퍼센트
                scorePercent = computeScorePercent(
                    selected: selectedIDs,
                    answers: answerIndices,
                    optionCount: options.count
                )
                showSummary = true
            } label: {
                Text("제출하기")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedIDs.isEmpty ? Color.gray.opacity(0.3) : Color.blue)
                    .foregroundColor(selectedIDs.isEmpty ? .gray : .white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(selectedIDs.isEmpty)
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .navigationTitle("문제 풀이")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showSummary) {
            // ✅ 퍼센트 기반 요약 뷰
            QuizSummaryScoreView(percent: scorePercent) {
                // 닫기 후 리셋
                currentIndex = 0
                selectedIDs.removeAll()
                showSummary = false
                scorePercent = 0
            }
            .presentationDetents([.fraction(0.85)])
        }
    }
}

// ✅ 부분점수 계산 로직
/// - hit: 맞게 고른 개수 / 정답 개수  → 기본 가산
/// - wrong: 오답 선택 개수 / (전체 보기 - 정답 수)  → 패널티 0.5배
/// - 최종: clamp( (hitRatio) - 0.5*(wrongRatio), 0...1 ) * 100
private func computeScorePercent(selected: Set<Int>, answers: Set<Int>, optionCount: Int) -> Int {
    let hit = selected.intersection(answers).count
    let wrong = selected.subtracting(answers).count

    let answerCount = max(1, answers.count)
    let nonAnswerCount = max(1, optionCount - answers.count) // 0 분모 방지

    let hitRatio = Double(hit) / Double(answerCount)
    let wrongRatio = Double(wrong) / Double(nonAnswerCount)

    // 패널티 가중치는 0.5 (원하면 0.3~1.0 사이로 조절)
    let raw = hitRatio - 0.5 * wrongRatio
    let clamped = max(0, min(1, raw))

    return Int(round(clamped * 100))
}

#Preview {
    NavigationStack { QuizSessionView() }
}
