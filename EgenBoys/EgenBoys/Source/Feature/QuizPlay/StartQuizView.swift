//
//  StartQuizView.swift
//  EgenBoys
//
//  Created by 정수안 on 8/11/25.
//

import SwiftUI
import SwiftData

struct StartQuizView: View {
    // SwiftData
    @Environment(\.modelContext) private var context
    @Query(sort: \Quiz.title, order: .forward) private var quizzes: [Quiz]

    // 상태
    @State private var selectedCategory: QuizCategory = .all
    @State private var difficulty: String = "보통"        // 표시용
    @State private var selectedIndex: Int = 0             // filteredQuizzes 내 인덱스

    private let difficulties = ["쉬움","보통","어려움"]

    // 필터 결과
    private var filteredQuizzes: [Quiz] {
        selectedCategory == .all ? quizzes : quizzes.filter { $0.category == selectedCategory }
    }
    private var selectedQuiz: Quiz? {
        guard filteredQuizzes.indices.contains(selectedIndex) else { return nil }
        return filteredQuizzes[selectedIndex]
    }
    private var isStartDisabled: Bool {
        filteredQuizzes.isEmpty || selectedQuiz == nil
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // 상단 타이틀
                VStack(alignment: .leading, spacing: 6) {
                    Text(selectedQuiz?.title ?? "퀴즈 선택")
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("난이도 및 카테고리")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // 카드형 설정 섹션
                VStack(spacing: 0) {
                    StartSettingRow(title: "난이도") {
                        Picker("", selection: $difficulty) {
                            ForEach(difficulties, id: \.self) { Text($0) }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                        .disabled(true) // 현재는 표시용
                    }

                    Divider().padding(.leading, 16)

                    StartSettingRow(title: "카테고리") {
                        Picker("", selection: $selectedCategory) {
                            ForEach(QuizCategory.allCases, id: \.self) {
                                Text($0.rawValue).tag($0)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                        .onChange(of: selectedCategory) { _ in
                            selectedIndex = 0
                        }
                    }

                    Divider().padding(.leading, 16)

                    StartSettingRow(title: "퀴즈 선택") {
                        if filteredQuizzes.isEmpty {
                            Text("데이터 없음")
                                .foregroundStyle(.secondary)
                                .font(.subheadline)
                        } else {
                            Picker("", selection: $selectedIndex) {
                                ForEach(filteredQuizzes.indices, id: \.self) { i in
                                    Text(filteredQuizzes[i].title).tag(i)
                                }
                            }
                            .pickerStyle(.menu)
                            .labelsHidden()
                            .frame(maxWidth: 240)
                        }
                    }
                }
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(.separator), lineWidth: 0.5)
                )

                // 데이터 없음 안내
                if quizzes.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("저장된 퀴즈가 없어요.")
                            .font(.subheadline.bold())
                        Text("퀴즈 목록에서 “데이터 추가하기”로 목 데이터를 만들거나, 편집 화면에서 퀴즈를 등록해 주세요.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 2)
                }

                Spacer(minLength: 8)

                // 시작 버튼
                NavigationLink {
                    if let quiz = selectedQuiz {
                        QuizSessionView(questions: quiz.toPlayQuestions())
                    } else {
                        QuizSessionView(questions: QuizQuestion.sample)
                    }
                } label: {
                    Text("시작하기")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(isStartDisabled ? Color.gray.opacity(0.25) : Color.blue)
                        .foregroundColor(isStartDisabled ? .gray : .white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(isStartDisabled)
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 32)
        }
        .navigationTitle("퀴즈 풀기")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - 재사용 가능한 행 컴포넌트 (간격/정렬 예쁘게)
private struct StartSettingRow<Content: View>: View {
    let title: String
    @ViewBuilder var trailing: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.trailing = content()
    }

    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.primary)
            Spacer(minLength: 12)
            trailing
                .font(.subheadline)
                .foregroundStyle(.blue)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
    }
}

#Preview {
    NavigationStack { StartQuizView() }
}

