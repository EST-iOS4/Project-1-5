//
//  QuizListVIew.swift
//  EgenBoys
//
//  Created by 이건준 on 8/11/25.
//

import SwiftUI

enum QuizCategory: String, CaseIterable {
    case all = "모든 퀴즈"
    case ios = "iOS"
    case design = "Design"
    case cs = "CS"
}

struct QuizListView: View {
    @State private var selectedCategory: QuizCategory = .all
    @State private var quizList: [QuizItem] = [
        QuizItem(
            title: "첫번째 퀴즈",
            description: "이 퀴즈는 SwiftUI에 대한 기본적인 이해를 테스트합니다.",
            imageURL: URL(string: "https://plus.unsplash.com/premium_photo-1668736594225-55e292fdd95e?w=700&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8JUVEJTgwJUI0JUVDJUE2JTg4fGVufDB8fDB8fHww"),
            videoURL: URL(string: "https://www.youtube.com/watch?v=dQw4w9WgXcQ"),
            category: .cs
        ),
        QuizItem(
            title: "두번째 퀴즈",
            description: "이 퀴즈는 Swift 언어에 대한 질문입니다.",
            imageURL: URL(string: "https://plus.unsplash.com/premium_photo-1678216286021-e81f66761751?w=700&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OXx8JUVEJTgwJUI0JUVDJUE2JTg4fGVufDB8fDB8fHww"),
            videoURL: URL(string: "https://www.youtube.com/watch?v=J---aiyznGQ"),
            category: .design
        ),
        QuizItem(
            title: "세번째 퀴즈",
            description: "iOS 개발에 관련된 다양한 기술적 질문을 다룹니다.",
            imageURL: URL(string: "https://images.unsplash.com/photo-1516321497487-e288fb19713f?w=700&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTB8fCVFRCU4MCVCNCVFQyVBNiU4OHxlbnwwfHwwfHx8MA%3D%3D"),
            videoURL: URL(string: "https://www.youtube.com/watch?v=QH2-TGUlwu4"),
            category: .ios
        )
    ]
    private var filteredQuizList: [QuizItem] {
        if selectedCategory == .all {
            return quizList
        } else {
            return quizList.filter { $0.category == selectedCategory }
        }
    }
    
    var body: some View {
        VStack {
            Picker("카테고리 선택", selection: $selectedCategory) {
                ForEach(QuizCategory.allCases, id: \.self) { category in
                    Text(category.rawValue).tag(category)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            List {
                ForEach(filteredQuizList) { item in
                    NavigationLink(destination: QuizDetailView(item: item)) {
                        QuizItemView(item: item)
                    }
                }
                .listRowInsets(EdgeInsets(top: .zero, leading: .zero, bottom: .zero, trailing: 15))
            }
            .animation(.easeInOut, value: selectedCategory)
        }
    }
}

#Preview {
    QuizListView()
}
