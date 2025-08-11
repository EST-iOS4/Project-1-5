//
//  MainTabView.swift
//  EgenBoys
//
//  Created by 이건준 on 8/8/25.
//

import SwiftUI

enum TabItem: String, CaseIterable {
    case quizList = "퀴즈 목록"
    case quizPlay = "퀴즈 풀기"
    case quizEditor = "퀴즈 등록"
    case dashboard = "대시보드"
    
    var imageName: String {
        switch self {
        case .quizList:
            return "list.dash"
        case .quizPlay:
            return "play.circle"
        case .quizEditor:
            return "square.and.pencil"
        case .dashboard:
            return "chart.bar"
        }
    }
    
    var title: String {
        return self.rawValue
    }
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .quizList:
            QuizListView()
        case .quizPlay:
            QuizPlayView()
        case .quizEditor:
            QuizEditorView()
        case .dashboard:
            DashboardView()
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            ForEach(TabItem.allCases, id: \.self) { tabItem in
                tabItem.view
                    .tabItem {
                        TabItemView(imageName: tabItem.imageName, text: tabItem.title)
                    }
            }
        }
    }
}

#Preview {
    MainTabView()
}
