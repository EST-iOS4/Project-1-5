//
//  QuizSessionView.swift
//  EgenBoys
//
//  Created by 정수안 on 8/11/25.
//

import SwiftUI


///
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
    @State private var selections: [Int: Set<Int>] = [:]   // 문항별 선택 저장
    @State private var revealed: Bool = false               // 정답 공개 여부
    @State private var showSummary = false
    @State private var finalPercent = 0

    // 여기 수정함!! Start 로 돌아가기 위해 pop
    @Environment(\.dismiss) private var dismiss
    @State private var popAfterSummary = false              // 시트 닫힌 뒤 pop 플래그

    
    init(questions: [QuizQuestion]? = nil) {
        self.questions = questions ?? QuizQuestion.sample
    }

    var body: some View {
        let total = max(questions.count, 1)
        let q = questions[index]
        let selected = selections[index] ?? []

        VStack(spacing: 16) {
          
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
                        VStack(spacing: 12) {

                            // ⬇️ 등록/편집 화면과 동일 톤의 설명 박스 추가
                            InfoNote(text: "정답으로 사용할 보기를 체크해주세요.")

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
            .disabled(selected.isEmpty && !revealed)   // 선택 전엔 공개 버튼 비활성화
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .navigationTitle("문제 풀이")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showSummary) {
            // ⬇️ 퍼센트 요약 시트 (total/correct 버전 써도 onClose 동일)
            QuizSummaryScoreView(percent: finalPercent) {
                // 시트 닫기 + 이후 pop하도록 표시
                popAfterSummary = true
                showSummary = false

                // (선택) 다음 풀이 대비 초기화
                index = 0
                selections.removeAll()
                revealed = false
                finalPercent = 0
            }
            .presentationDetents([.fraction(0.85)])
        }
        // 시트가 실제로 닫힌 시점에 Start 화면으로 pop
        .onChange(of: showSummary) { isPresented in
            if !isPresented && popAfterSummary {
                popAfterSummary = false
                dismiss()   // ← NavigationStack에서 한 단계 뒤로
            }
        }
    }

    // 각 옵션의 피드백 상태 계산
    private func feedbackState(for i: Int, selected: Set<Int>, answers: Set<Int>) -> ChoiceFeedback? {
        guard revealed else { return nil } // 공개 전엔 색상 피드백 없음
        if answers.contains(i) { return .correct }      // 정답 = 초록
        if selected.contains(i) { return .wrong }       // 선택한 오답 = 빨강
        return .dimmed                                  // 나머지 흐리게
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
    NavigationStack { QuizSessionView() }   // 샘플 데이터로 미리보기
}

