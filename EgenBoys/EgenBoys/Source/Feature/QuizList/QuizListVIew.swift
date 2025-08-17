//
//  QuizListView.swift
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
    
    var body: some View {
        VStack {
            // 카테고리 필터
            Picker("카테고리 선택", selection: $selectedCategory) {
                ForEach(QuizCategory.allCases, id: \.self) { category in
                    Text(category.rawValue).tag(category)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            // 목록
            List {
                ForEach(filteredQuizList) { item in
                  // ✅ 이걸로 유지/되돌리기
                  NavigationLink(destination: QuizDetailView(item: item)) {
                      QuizItemView(item: item)
                  }

                }
                .listRowInsets(EdgeInsets(top: .zero, leading: .zero, bottom: .zero, trailing: 15))
            }
            .animation(.easeInOut, value: selectedCategory)
            
            /// TODO: - SwiftData MockData 추가 버튼 (나중에 삭제 예정)
            Button("데이터 추가하기") {
                addMockData()
            }
            .padding(.vertical, 8)
        }
        .navigationTitle("퀴즈 목록")
    }
    
    // 필터 적용된 리스트
    private var filteredQuizList: [Quiz] {
        if selectedCategory == .all {
            return quizList
        } else {
            return quizList.filter { $0.category == selectedCategory }
        }
    }
    
    // 목 데이터 삽입 (SwiftData)
    private func addMockData() {
        let question1 = Question(content: "Swift의 주요 특징은?", isCorrect: true)
        let question2 = Question(content: "Swift는 객체 지향 언어인가?", isCorrect: false)
        let question3 = Question(content: "옵셔널은 무엇인가요?", isCorrect: true)
        let question4 = Question(content: "Swift에서 `guard`문은 언제 사용하나요?", isCorrect: true)
        let question5 = Question(content: "Swift에서 `defer` 문을 사용할 때의 특징은 무엇인가요?", isCorrect: false)
        let question6 = Question(content: "Swift에서 `class`와 `struct`의 차이점은?", isCorrect: true)
        let question7 = Question(content: "Swift에서 `typealias`는 어떤 역할을 하나요?", isCorrect: false)
        
        let quiz1 = Quiz(
            title: "Swift 기초 퀴즈 1",
            explanation: "Swift 기본 개념을 테스트하는 퀴즈",
            category: .ios,
            questions: [question1, question2, question3],
            imageURL: URL(string: "https://images.unsplash.com/photo-1542736637-74169a802172?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mjh8fCVFQSVCNyU4MCVFQyU5NyVBQyVFQyU5QSVCNCUyMCVFQiU5RSU5OCVFQyU4NCU5QyVFRCU4QyU5MCVFQiU4QiVBNHxlbnwwfHwwfHx8MA%3D%3D"),
            videoURL: URL(string: "https://www.youtube.com/watch?v=dQw4w9WgXcQ"),
            difficultty: .easy
        )
        
        let quiz2 = Quiz(
            title: "Swift 기초 퀴즈 2",
            explanation: "Swift 기본 문법을 점검하는 퀴즈",
            category: .design,
            questions: [question4, question5],
            imageURL: URL(string: "https://images.unsplash.com/photo-1593085512500-5d55148d6f0d?w=1400&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8JUVDJUJBJTkwJUVCJUE2JUFEJUVEJTg0JUIwfGVufDB8fDB8fHww"),
            videoURL: URL(string: "https://www.youtube.com/watch?v=khWf78gd8G4"),
            difficultty: .medium
        )
        
        let quiz3 = Quiz(
            title: "iOS 앱 성능 최적화 퀴즈",
            explanation: "iOS 앱의 성능 최적화를 다루는 퀴즈",
            category: .ios,
            questions: [question1, question2, question6],
            imageURL: URL(string: "https://images.unsplash.com/photo-1615946027884-5b6623222bf4?w=1400&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Nnx8JUVDJUJBJTkwJUVCJUE2JUFEJUVEJTg0JUIwfGVufDB8fDB8fHww"),
            videoURL: URL(string: "https://www.youtube.com/watch?v=vJ0KNpMjTmI"),
            difficultty: .hard
        )
        
        let quiz4 = Quiz(
            title: "Swift 기본 문법 퀴즈",
            explanation: "Swift의 기본 문법을 점검하는 퀴즈",
            category: .design,
            questions: [question3, question7],
            imageURL: URL(string: "https://images.unsplash.com/photo-1618336753974-aae8e04506aa?w=1400&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OHx8JUVDJUJBJTkwJUVCJUE2JUFEJUVEJTg0JUIwfGVufDB8fDB8fHww"),
            videoURL: URL(string: "https://www.youtube.com/watch?v=aLV9E0J0Q9Y"),
            difficultty: .easy
        )
        
        let quiz5 = Quiz(
            title: "SwiftUI 기초 퀴즈",
            explanation: "SwiftUI 기본을 다루는 퀴즈",
            category: .design,
            questions: [question4],
            imageURL: URL(string: "https://images.unsplash.com/photo-1638803040283-7a5ffd48dad5?w=1400&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTB8fCVFQyVCQSU5MCVFQiVBNiVBRCVFRCU4NCVCMHxlbnwwfHwwfHx8MA%3D%3D"),
            videoURL: URL(string: "https://www.youtube.com/watch?v=QH2-TGUlwu4"),
            difficultty: .medium
        )
        
        let quiz6 = Quiz(
            title: "Python 기초 문법",
            explanation: "Python 언어 기초 문법을 배우는 퀴즈",
            category: .cs,
            questions: [question5],
            imageURL: URL(string: "https://images.unsplash.com/photo-1563823251941-b9989d1e8d97?w=1400&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTJ8fCVFQyVCQSU5MCVFQiVBNiVBRCVFRCU4NCVCMHxlbnwwfHwwfHx8MA%3D%3D"),
            videoURL: URL(string: "https://www.youtube.com/watch?v=f4HSe27H7Zc"),
            difficultty: .hard
        )
        
        let quiz7 = Quiz(
            title: "Objective-C vs Swift 퀴즈",
            explanation: "Objective-C와 Swift의 차이점을 비교하는 퀴즈",
            category: .cs,
            questions: [question6],
            imageURL: URL(string: "https://images.unsplash.com/photo-1637164011965-635d3e762a38?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OHx8JUVEJThGJUFDJUVDJUJDJTkzJUVCJUFBJUFDfGVufDB8fDB8fHww"),
            videoURL: URL(string: "https://www.youtube.com/watch?v=hdv4-FMmrpg"),
            difficultty: .easy
        )
        
        let quiz8 = Quiz(
            title: "UX/UI 디자인 퀴즈",
            explanation: "UX/UI 디자인에 대한 기초를 배우는 퀴즈",
            category: .design,
            questions: [question3],
            imageURL: URL(string: "https://images.unsplash.com/photo-1609372332255-611485350f25?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTB8fCVFRCU4RiVBQyVFQyVCQyU5MyVFQiVBQSVBQ3xlbnwwfHwwfHx8MA%3D%3D"),
            videoURL: URL(string: "https://www.youtube.com/watch?v=aLV9E0J0Q9Y"),
            difficultty: .medium
        )
        
        let quiz9 = Quiz(
            title: "JavaScript 기본 문법",
            explanation: "JavaScript의 기본 문법을 배우는 퀴즈",
            category: .cs,
            questions: [question1],
            imageURL: URL(string: "https://images.unsplash.com/photo-1605979257913-1704eb7b6246?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTF8fCVFRCU4RiVBQyVFQyVCQyU5MyVFQiVBQSVBQ3xlbnwwfHwwfHx8MA%3D%3D"),
            videoURL: URL(string: "https://www.youtube.com/watch?v=tvuwL0xrwZI"),
            difficultty: .hard
        )
        
        let quiz10 = Quiz(
            title: "iOS 앱 디자인 패턴",
            explanation: "iOS 앱 개발에서 자주 사용하는 디자인 패턴에 대한 퀴즈입니다.",
            category: .ios,
            questions: [question2],
            imageURL: URL(string: "https://images.unsplash.com/photo-1530041539828-114de669390e?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MjR8fCVFQSVCNyU4MCVFQyU5NyVBQyVFQyU5QSVCNHxlbnwwfHwwfHx8MA%3D%3D"),
            videoURL: URL(string: "https://www.youtube.com/watch?v=hdv4-FMmrpg"),
            difficultty: .easy
        )
        
        do {
            modelContext.insert(quiz1)
            modelContext.insert(quiz2)
            modelContext.insert(quiz3)
            modelContext.insert(quiz4)
            modelContext.insert(quiz5)
            modelContext.insert(quiz6)
            modelContext.insert(quiz7)
            modelContext.insert(quiz8)
            modelContext.insert(quiz9)
            modelContext.insert(quiz10)
            try modelContext.save()
        } catch {
            print("목 데이터 삽입 오류: \(error)")
        }
    }
}

#Preview {
    NavigationStack {
        QuizListView()
    }
}

