//
//  QuizListVIew.swift
//  EgenBoys
//
//  Created by 이건준 on 8/11/25.
//

import SwiftUI
import SwiftData

struct QuizListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var quizList: [Quiz]
    @State private var selectedCategory: QuizCategory = .all
    
    @State private var isShowingEditor = false
    @State private var quizToEdit: Quiz?
    
    var body: some View {
        VStack(spacing: 8) {
            Picker("카테고리 선택", selection: $selectedCategory) {
                ForEach(QuizCategory.allCases, id: \.self) { category in
                    Text(category.rawValue).tag(category)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
            List {
                ForEach(filteredQuizList) { item in
                    NavigationLink(destination: QuizDetailView(item: item)) {
                        QuizItemView(item: item)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            deleteQuiz(item)
                        } label: {
                            Label("삭제", systemImage: "trash")
                        }
                        Button {
                            quizToEdit = item
                            isShowingEditor = true
                        } label: {
                            Label("편집", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                }
                .listRowInsets(EdgeInsets(top: .zero, leading: .zero, bottom: .zero, trailing: 15))
            }
            .contentMargins(.all, 16)
            .animation(.easeInOut, value: selectedCategory)
            .sheet(isPresented: $isShowingEditor) {
                if let quiz = quizToEdit {
                    QuizEditorView(quizToEdit: quiz)
                }
            }
            
            /// TODO: - SwiftData MockData추가를 위한 버튼, 이후 삭제 예정
            Button("데이터 추가하기") {
                addMockData()
            }
        }
        .navigationTitle("퀴즈 목록")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var filteredQuizList: [Quiz] {
        if selectedCategory == .all {
            return quizList
        } else {
            return quizList.filter { $0.category == selectedCategory }
        }
    }
    
    private func deleteQuiz(_ quiz: Quiz) {
        modelContext.delete(quiz)
        do {
            try modelContext.save()
        } catch {
            print("퀴즈 삭제 실패: \(error)")
        }
    }
    
    private func addMockData() {
        // MARK: - Seed 7 Quizzes (each with 3~4 Questions)

        do {
            // 1) Swift 기초
            let q1_1 = Question(content: "Swift는 타입 안전성과 타입 추론을 지원한다.", isCorrect: true)
            let q1_2 = Question(content: "Swift에서 변수는 기본적으로 불변(immutable)이다.", isCorrect: false)
            let q1_3 = Question(content: "Swift의 옵셔널은 값이 없을 수 있음을 표현한다.", isCorrect: true)

            let quiz1 = Quiz(
                title: "Swift 기초",
                explanation: "Swift의 핵심 개념을 점검하는 퀴즈",
                category: .ios,
                questions: [q1_1, q1_2, q1_3],
                imageURL: URL(string: "https://images.unsplash.com/photo-1542736637-74169a802172?w=1200&auto=format&fit=crop&q=60"),
                videoURL: URL(string: "https://www.youtube.com/watch?v=vJ0KNpMjTmI"),
                difficultty: .easy
            )

            // 2) Swift 문법
            let q2_1 = Question(content: "`guard` 구문은 조기 종료를 통해 가독성을 높인다.", isCorrect: true)
            let q2_2 = Question(content: "`defer`는 블록 시작 시 즉시 실행된다.", isCorrect: false)
            let q2_3 = Question(content: "`if let`은 옵셔널 바인딩에 사용된다.", isCorrect: true)
            let q2_4 = Question(content: "`switch`는 기본적으로 break가 필요하다.", isCorrect: false)

            let quiz2 = Quiz(
                title: "Swift 문법",
                explanation: "제어문, 옵셔널 바인딩 등 기본 문법 확인",
                category: .ios,
                questions: [q2_1, q2_2, q2_3, q2_4],
                imageURL: URL(string: "https://images.unsplash.com/photo-1593085512500-5d55148d6f0d?w=1200&auto=format&fit=crop&q=60"),
                videoURL: URL(string: "https://www.youtube.com/watch?v=QH2-TGUlwu4"),
                difficultty: .easy
            )

            // 3) iOS 메모리 관리
            let q3_1 = Question(content: "ARC는 참조 횟수 기반으로 메모리를 관리한다.", isCorrect: true)
            let q3_2 = Question(content: "강한 순환 참조는 메모리 누수로 이어질 수 있다.", isCorrect: true)
            let q3_3 = Question(content: "클로저의 캡처 리스트는 순환 참조 예방에 도움된다.", isCorrect: true)

            let quiz3 = Quiz(
                title: "iOS 메모리 관리",
                explanation: "ARC, 순환 참조, 캡처 리스트 등을 다루는 퀴즈",
                category: .ios,
                questions: [q3_1, q3_2, q3_3],
                imageURL: URL(string: "https://images.unsplash.com/photo-1615946027884-5b6623222bf4?w=1200&auto=format&fit=crop&q=60"),
                videoURL: URL(string: "https://www.youtube.com/watch?v=aLV9E0J0Q9Y"),
                difficultty: .medium
            )

            // 4) 동시성(Concurrency)
            let q4_1 = Question(content: "GCD는 큐 기반으로 작업을 스케줄링한다.", isCorrect: true)
            let q4_2 = Question(content: "Race condition은 동기화가 과도할 때만 발생한다.", isCorrect: false)
            let q4_3 = Question(content: "Swift Concurrency의 actor는 데이터 경합을 줄이는 데 도움된다.", isCorrect: true)
            let q4_4 = Question(content: "Deadlock은 락 순서가 고정되어 있어도 발생할 수 있다.", isCorrect: false)

            let quiz4 = Quiz(
                title: "동시성(Concurrency)",
                explanation: "GCD, 동기화, actor 등 동시성 기초 점검",
                category: .cs,
                questions: [q4_1, q4_2, q4_3, q4_4],
                imageURL: URL(string: "https://images.unsplash.com/photo-1618336753974-aae8e04506aa?w=1200&auto=format&fit=crop&q=60"),
                videoURL: URL(string: "https://www.youtube.com/watch?v=khWf78gd8G4"),
                difficultty: .medium
            )

            // 5) UI/UX 접근성
            let q5_1 = Question(content: "VoiceOver는 화면 요소에 대한 접근성을 제공한다.", isCorrect: true)
            let q5_2 = Question(content: "Dynamic Type은 글자 크기 변경을 지원한다.", isCorrect: true)
            let q5_3 = Question(content: "색 대비는 접근성과 무관하다.", isCorrect: false)

            let quiz5 = Quiz(
                title: "UI/UX 접근성",
                explanation: "iOS 접근성(VoiceOver, Dynamic Type, 대비) 기본",
                category: .design,
                questions: [q5_1, q5_2, q5_3],
                imageURL: URL(string: "https://images.unsplash.com/photo-1609372332255-611485350f25?w=1200&auto=format&fit=crop&q=60"),
                videoURL: URL(string: "https://www.youtube.com/watch?v=tvuwL0xrwZI"),
                difficultty: .easy
            )

            // 6) 네트워킹 기본
            let q6_1 = Question(content: "HTTP는 요청-응답 모델을 따른다.", isCorrect: true)
            let q6_2 = Question(content: "REST API는 상태 저장(stateful)을 권장한다.", isCorrect: false)
            let q6_3 = Question(content: "URLSession은 iOS의 기본 네트워킹 API이다.", isCorrect: true)
            let q6_4 = Question(content: "JSON 인코딩/디코딩은 Codable로 손쉽게 처리 가능하다.", isCorrect: true)

            let quiz6 = Quiz(
                title: "네트워킹 기본",
                explanation: "HTTP, REST, URLSession, Codable 기초",
                category: .cs,
                questions: [q6_1, q6_2, q6_3, q6_4],
                imageURL: URL(string: "https://images.unsplash.com/photo-1530041539828-114de669390e?w=1200&auto=format&fit=crop&q=60"),
                videoURL: URL(string: "https://www.youtube.com/watch?v=f4HSe27H7Zc"),
                difficultty: .medium
            )

            // 7) 디자인 패턴
            let q7_1 = Question(content: "MVVM은 뷰모델이 상태를 노출하고 바인딩을 담당한다.", isCorrect: true)
            let q7_2 = Question(content: "싱글톤 패턴은 전역 상태 남용 위험이 있다.", isCorrect: true)
            let q7_3 = Question(content: "의존성 주입(DI)은 결합도를 높이는 기법이다.", isCorrect: false)

            let quiz7 = Quiz(
                title: "디자인 패턴",
                explanation: "MVVM, 싱글톤, DI 등 자주 쓰는 패턴",
                category: .ios,
                questions: [q7_1, q7_2, q7_3],
                imageURL: URL(string: "https://images.unsplash.com/photo-1530041539828-114de669390e?w=1200&auto=format&fit=crop&q=60"),
                videoURL: URL(string: "https://www.youtube.com/watch?v=hdv4-FMmrpg"),
                difficultty: .hard
            )

            // Insert & Save
            modelContext.insert(quiz1)
            modelContext.insert(quiz2)
            modelContext.insert(quiz3)
            modelContext.insert(quiz4)
            modelContext.insert(quiz5)
            modelContext.insert(quiz6)
            modelContext.insert(quiz7)

            try modelContext.save()
            print("목 데이터 7개 삽입 성공")

        } catch {
            print("목 데이터 삽입 오류: \(error)")
        }

        
    }
}

#Preview {
    QuizListView()
}

