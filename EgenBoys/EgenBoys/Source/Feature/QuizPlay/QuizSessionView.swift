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
    // ✅ N문제 받아서 풀이 (없으면 샘플로 대체)
    let questions: [QuizQuestion]
    @State private var index: Int = 0
    @State private var selections: [Int: Set<Int>] = [:]   // 문항별 선택 저장
    @State private var showSummary = false
    @State private var finalPercent = 0

    // ✅ 디폴트 init: 인자로 안 주면 샘플 사용
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
                    .font(.footnote)
                    .foregroundStyle(.secondary)
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
                                    isSelected: selected.contains(i)
                                )
                                .onTapGesture {
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

            Button {
                if index < total - 1 {
                    index += 1
                } else {
                    finalPercent = overallPercent()
                    showSummary = true
                }
            } label: {
                Text(index == total - 1 ? "제출하기" : "다음으로")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selected.isEmpty ? Color.gray.opacity(0.3) : Color.blue)
                    .foregroundColor(selected.isEmpty ? .gray : .white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(selected.isEmpty)
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .navigationTitle("문제 풀이")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showSummary) {
            QuizSummaryScoreView(percent: finalPercent) {
                index = 0
                selections.removeAll()
                showSummary = false
                finalPercent = 0
            }
            .presentationDetents([.fraction(0.85)])
        }
    }

    // 각 문항 점수(%) 평균
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

// 그대로 사용
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
    // 샘플 주입 없이도 동작(디폴트 init)
    NavigationStack { QuizSessionView() }
}
