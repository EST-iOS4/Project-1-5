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

    @State private var questionText: String =
        "질문"
    @State private var options: [String] = [
        "@1", "@2", "@3", "@4"
    ]
    
    private let answerIndex: Int = 1

    @State private var selectedID: Int? = nil

    @State private var showSummary = false
    @State private var dummyCorrect = 0  // 제출 시 계산해서 채움

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
                                CheckboxRow(index: i+1,
                                            text: options[i],
                                            isSelected: selectedID == i)
                                .onTapGesture { selectedID = i }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
            }

            // 하단 버튼
            Button {
                // ✅ 제출 시 정답 체크
                dummyCorrect = (selectedID == answerIndex) ? 1 : 0
                showSummary = true
            } label: {
                Text("제출하기")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background((selectedID == nil) ? Color.gray.opacity(0.3) : Color.blue)
                    .foregroundColor((selectedID == nil) ? .gray : .white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(selectedID == nil)
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
        }
        .navigationTitle("문제 풀이")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showSummary) {
            QuizSummaryView(total: totalCount, correct: dummyCorrect) {
                // 닫기 후 리셋
                currentIndex = 0
                selectedID = nil
                showSummary = false
                dummyCorrect = 0
            }
            .presentationDetents([.fraction(0.85)])
        }
    }
}

#Preview {
    NavigationStack { QuizSessionView() }
}
