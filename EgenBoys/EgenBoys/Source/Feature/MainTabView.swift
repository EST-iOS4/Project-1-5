//
//  MainTabView.swift
//  EgenBoys
//
//  Created by 이건준 on 8/8/25.
//

import SwiftUI

enum TabItem: String, CaseIterable, Hashable {
    case quizList = "퀴즈 목록"
    case quizPlay = "퀴즈 풀기"
    case quizEditor = "퀴즈 등록"
    case dashboard = "대시보드"

    var imageName: String {
        switch self {
        case .quizList:  return "list.bullet"
        case .quizPlay:  return "play.circle"
        case .quizEditor:return "square.and.pencil"
        case .dashboard: return "chart.bar"
        }
    }

    var title: String { rawValue }
}

struct MainTabView: View {
    @State private var selection: TabItem = .quizList

    var body: some View {
        TabView(selection: $selection) {

            // 1) 퀴즈 목록
            NavigationStack {
                QuizListView()
            }
            .tabItem { TabItemView(imageName: TabItem.quizList.imageName, text: TabItem.quizList.title) }
            .tag(TabItem.quizList)

            // 2) 퀴즈 풀기 (시작/세션 네비게이션은 내부에서 처리)
            NavigationStack {
                QuizPlayView()
            }
            .tabItem { TabItemView(imageName: TabItem.quizPlay.imageName, text: TabItem.quizPlay.title) }
            .tag(TabItem.quizPlay)

            // 3) 퀴즈 등록
            NavigationStack {
                QuizEditorView()
            }
            .tabItem { TabItemView(imageName: TabItem.quizEditor.imageName, text: TabItem.quizEditor.title) }
            .tag(TabItem.quizEditor)

            // 4) 대시보드 (없으면 임시 화면)
            NavigationStack {
                DashboardView() // 대체: Text("대시보드").padding()
            }
            .tabItem { TabItemView(imageName: TabItem.dashboard.imageName, text: TabItem.dashboard.title) }
            .tag(TabItem.dashboard)
        }
    }
}

#Preview {
    MainTabView()
}

