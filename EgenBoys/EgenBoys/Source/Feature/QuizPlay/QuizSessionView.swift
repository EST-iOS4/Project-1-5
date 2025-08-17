//
//  QuizSessionView.swift
//  EgenBoys
//
//  Created by 정수안 on 8/11/25.
//

import SwiftUI

/// ⬇️ 안내 라벨
private struct InfoNote: View {
    var text: String
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .imageScale(.medium)
                .foregroundStyle(.blue)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .combine)
    }
}

struct QuizSessionView: View {

    let questions: [QuizQuestion]
    @State private var index: Int = 0
    @State private var selections: [Int: Set<Int>] = [:]   // 문항별(보정된 보기 기준) 선택 저장
    @State private var revealed: Bool = false              // 정답 공개 여부
    @State private var showSummary = false
    @State private var finalPercent = 0

    @Environment(\.dismiss) private var dismiss
    @State private var popAfterSummary = false

    init(questions: [QuizQuestion]? = nil) {
        self.questions = questions ?? QuizQuestion.sample
    }

    var body: some View {
        let total = max(questions.count, 1)

        // 원본 문항
        let raw = questions[index]

        // ✅ “보기의 첫 항목을 문제로 승격” 보정 데이터
        let displayed = displayedData(from: raw)
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
                        Text(displayed.text) // ← 보기[0]이 문제로 노출
                            .font(.title3.bold())
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    SectionCard("보기") {
                        VStack(spacing: 12) {
                            InfoNote(text: "정답으로 사용할 보기를 체크해주세요.")

                            VStack(spacing: 10) {
                                ForEach(displayed.options.indices, id: \.self) { i in
                                    CheckboxRow(
                                        index: i + 1,
                                        text: displayed.options[i],
                                        isSelected: selected.contains(i),
                                        feedback: feedbackState(
                                            for: i,
                                            selected: selected,
                                            answers: displayed.answerIndices
                                        )
                                    )
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        guard !revealed else { return } // 공개 후엔 잠금
                                        var s = selections[index] ?? []
                                        if s.contains(i) { s.remove(i) } else { s.insert(i) }
                                        selections[index] = s
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
                if !revealed {
                    revealed = true
                } else {
                    if index < total - 1 {
                        index += 1
                        revealed = false
                    } else {
                        finalPercent = overallPercent() // 모든 문항을 보정 기준으로 채점
                        showSummary = true
                    }
                }
            } label: {
                Text(!revealed ? "정답 확인" : (index == total - 1 ? "제출하기" : "다음으로"))
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background((selected.isEmpty && !revealed) ? Color.gray.opacity(0.3) : Color.blue)
                    .foregroundColor((selected.isEmpty && !revealed) ? .gray : .white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(selected.isEmpty && !revealed)
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .navigationTitle("문제 풀이")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showSummary) {
            QuizSummaryScoreView(percent: finalPercent) {
                popAfterSummary = true
                showSummary = false

                // 다음 풀이 대비 초기화
                index = 0
                selections.removeAll()
                revealed = false
                finalPercent = 0
            }
            .presentationDetents([.fraction(0.85)])
        }
        .onChange(of: showSummary) { isPresented in
            if !isPresented && popAfterSummary {
                popAfterSummary = false
                dismiss()
            }
        }
    }

    // MARK: - 보정 유틸
    /// 보기의 첫 번째를 '문제'로 승격하고 나머지를 보기로 사용
    /// 정답 인덱스는 0 제거 보정으로 -1 시프트
    private func displayedData(from raw: QuizQuestion) -> (text: String, options: [String], answerIndices: Set<Int>) {
        let questionText = raw.options.first ?? raw.text
        let options = Array(raw.options.dropFirst())
        let answers = Set(raw.answerIndices.compactMap { idx in
            idx == 0 ? nil : idx - 1
        })
        return (questionText, options, answers)
    }

    // 각 옵션의 피드백 상태 계산 (보정된 보기 인덱스 기반)
    private func feedbackState(for i: Int, selected: Set<Int>, answers: Set<Int>) -> ChoiceFeedback? {
        guard revealed else { return nil }
        if answers.contains(i) { return .correct }
        if selected.contains(i) { return .wrong }
        return .dimmed
    }

    // 전체 점수(%): 각 문항을 보정 데이터 기준으로 채점
    private func overallPercent() -> Int {
        guard !questions.isEmpty else { return 0 }
        let percents: [Int] = questions.enumerated().map { (idx, q) in
            let d = displayedData(from: q)
            return computeScorePercent(
                selected: selections[idx] ?? [],
                answers: d.answerIndices,
                optionCount: d.options.count
            )
        }
        let avg = Double(percents.reduce(0, +)) / Double(percents.count)
        return Int(round(avg))
    }
}

// 부분 점수 계산 로직 (기존과 동일)
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

