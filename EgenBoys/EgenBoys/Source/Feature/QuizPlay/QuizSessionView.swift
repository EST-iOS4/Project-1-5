//
//  QuizSessionView.swift
//  EgenBoys
//
//  Created by 정수안 on 8/11/25.
//

import SwiftUI

// 세션에서 쓰는 질문 모델은 QuizPlayModels.swift에 있음:
// struct QuizQuestion { let text: String; let options: [String]; let answerIndices: Set<Int> }


struct QuizSessionView: View {
    let questions: [QuizQuestion]
    @State private var index: Int = 0
    @State private var selections: [Int: Set<Int>] = [:]
    @State private var revealed: Bool = false               // ✅ 정답 공개 여부
    @State private var showSummary = false
    @State private var finalPercent = 0

    init(questions: [QuizQuestion]? = nil) {
        self.questions = questions ?? QuizQuestion.sample
    }

    var body: some View {
        let total = max(questions.count, 1)
        let q = questions[index]
        let selected = selections[index] ?? []

        VStack(spacing: 16) {
            // 진행도
            VStack(spacing: 6) {
                ProgressView(value: Double(index + 1), total: Double(total))
                    .tint(.blue)
                    .padding(.horizontal)
                Text("\(index + 1) / \(total)")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            .padding(.top, 6)

            ScrollView {
                VStack(spacing: 16) {
                    SectionCard("문제") {
                        Text(q.text)
                            .font(.title3.bold())
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    SectionCard("보기") {
                        VStack(spacing: 10) {
                            ForEach(q.options.indices, id: \.self) { i in
                                CheckboxRow(
                                    index: i + 1,
                                    text: q.options[i],
                                    isSelected: selected.contains(i),
                                    feedback: feedbackState(for: i, selected: selected, answers: q.answerIndices)
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    guard !revealed else { return } // 공개 후에는 잠금
                                    var s = selections[index] ?? []
                                    if s.contains(i) { s.remove(i) } else { s.insert(i) }
                                    selections[index] = s
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
            }

            // 하단 버튼: 공개 전엔 "정답 확인", 공개 후엔 "다음/제출"
            Button {
                if !revealed {
                    // 1) 정답 색상 공개
                    revealed = true
                } else {
                    // 2) 다음 문제 또는 제출
                    if index < total - 1 {
                        index += 1
                        revealed = false
                    } else {
                        finalPercent = overallPercent()
                        showSummary = true
                    }
                }
            } label: {
                Text(!revealed
                     ? "정답 확인"
                     : (index == total - 1 ? "제출하기" : "다음으로"))
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background((selected.isEmpty && !revealed) ? Color.gray.opacity(0.3) : Color.blue)
                    .foregroundColor((selected.isEmpty && !revealed) ? .gray : .white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(selected.isEmpty && !revealed)   // 선택 전에는 공개 버튼 비활성화
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .navigationTitle("문제 풀이")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showSummary) {
            QuizSummaryScoreView(percent: finalPercent) {
                index = 0
                selections.removeAll()
                revealed = false
                showSummary = false
                finalPercent = 0
            }
            .presentationDetents([.fraction(0.85)])
        }
    }

    // ✅ 각 옵션의 피드백 상태 계산
    private func feedbackState(for i: Int, selected: Set<Int>, answers: Set<Int>) -> ChoiceFeedback? {
        guard revealed else { return nil } // 공개 전엔 색상 피드백 없음

        if answers.contains(i) {                 // 정답은 초록(선택 여부 무관)
            return .correct
        } else if selected.contains(i) {         // 선택한 오답은 빨강
            return .wrong
        } else {                                 // 나머지는 흐리게
            return .dimmed
        }
    }

    // 전체 점수(%): 각 문항 점수 평균
    private func overallPercent() -> Int {
        guard !questions.isEmpty else { return 0 }
        let percents = questions.enumerated().map { (idx, q) in
            computeScorePercent(
                selected: selections[idx] ?? [],
                answers: q.answerIndices,
                optionCount: q.options.count
            )
        }
        let avg = Double(percents.reduce(0, +)) / Double(percents.count)
        return Int(round(avg))
    }
}

// 기존 함수 재사용
private func computeScorePercent(selected: Set<Int>, answers: Set<Int>, optionCount: Int) -> Int {
    let hit = selected.intersection(answers).count
    let wrong = selected.subtracting(answers).count
    let answerCount = max(1, answers.count)
    let nonAnswerCount = max(1, optionCount - answers.count)
    let hitRatio = Double(hit) / Double(answerCount)
    let wrongRatio = Double(wrong) / Double(nonAnswerCount)
    let raw = hitRatio - 0.5 * wrongRatio
    return Int(round(max(0, min(1, raw)) * 100))
}

#Preview {
    NavigationStack { QuizSessionView() }
}
