//
//  StartQuizView.swift
//  EgenBoys
//
//  Created by 정수안 on 8/11/25.
//

import SwiftUI
import SwiftData

struct StartQuizView: View {
    @State private var difficulty: Difficulty = .medium
    @State private var category: QuizCategory = .ios
    @Query private var quizList: [Quiz]
    
    @State private var showNoQuizAlert = false
    @State private var goToSession = false
    
    private let difficulties = Difficulty.allCases
    private let categories   = QuizCategory.allCases
    
    private var filteredQuizList: [QuizQuestion] {
        quizList.filter { $0.difficultty == difficulty && $0.category == category }.map {
            .init(
                text: $0.title,
                options: $0.questions.map { $0.content },
                answerIndices: Set($0.questions.enumerated().filter { $0.element.isCorrect }.map { $0.offset })
            )
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(alignment: .center, spacing: 16) {
                    SectionCard("난이도 및 카테고리") {
                        HStack {
                            Text("난이도")
                                .withCustomFont()
                            Spacer()
                            Picker("", selection: $difficulty) {
                                ForEach(difficulties, id: \.self) { Text($0.rawValue) }
                            }
                            .pickerStyle(.menu)
                        }
                        .padding(14)
                        
                        Divider()
                        
                        HStack {
                            Text("카테고리")
                                .withCustomFont()
                            Spacer()
                            Picker("", selection: $category) {
                                ForEach(categories, id: \.self) { Text($0.rawValue) }
                            }
                            .pickerStyle(.menu)
                        }
                        .padding(14)
                    }
                    
                    // 목적지 네비게이션은 숨겨두고 상태로 트리거
                    NavigationLink(
                        "",
                        destination: QuizSessionView(questions: filteredQuizList),
                        isActive: $goToSession
                    )
                    .hidden()
                    
                    // 실제로 탭하는 버튼
                    Button {
                        if filteredQuizList.isEmpty {
                            showNoQuizAlert = true
                        } else {
                            goToSession = true
                        }
                    } label: {
                        Text("시작하기")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding()
                .frame(maxWidth: 560)                       // (옵션) 컨텐츠 최대 폭 제한
                .frame(maxWidth: .infinity)                 // 수평 중앙
                .frame(minHeight: geo.size.height,          // 뷰포트 높이만큼 최소 높이 확보
                       alignment: .center)                  // 수직 중앙 정렬
            }
            .frame(width: geo.size.width, height: geo.size.height) // 스크롤뷰가 뷰포트를 꽉 채우도록
        }
        .navigationTitle("퀴즈 풀기")
        .navigationBarTitleDisplayMode(.large)
        .alert("문제를 찾을 수 없어요", isPresented: $showNoQuizAlert) {
            Button("확인", role: .cancel) { }
        } message: {
            Text("\(difficulty.rawValue) · \(category.rawValue) 조건의 문제가 없습니다.")
        }
    }
    
}

#Preview {
    NavigationStack { StartQuizView() }
}
