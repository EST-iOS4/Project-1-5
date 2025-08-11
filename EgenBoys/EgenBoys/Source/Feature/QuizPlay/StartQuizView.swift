//
//  StartQuizView.swift
//  EgenBoys
//
//  Created by 정수안 on 8/11/25.
//

import SwiftUI

struct StartQuizView: View {
    @State private var difficulty: String = "보통"
    @State private var category: String = "iOS"
    
    private let difficulties = ["쉬움","보통","어려움"]
    private let categories   = ["iOS","Swift","알고리즘","기타"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                SectionCard("난이도 및 카테고리") {
                    HStack {
                        Text("난이도")
                        Spacer()
                        Picker("", selection: $difficulty) {
                            ForEach(difficulties, id: \.self) { Text($0) }
                        }
                        .pickerStyle(.menu)
                    }
                    Divider()
                    HStack {
                        Text("카테고리")
                        Spacer()
                        Picker("", selection: $category) {
                            ForEach(categories, id: \.self) { Text($0) }
                        }
                        .pickerStyle(.menu)
                    }
                }
                
                NavigationLink {
                    // 실제 데이터 연동 전: UI 확인용 더미 세션
                    QuizSessionView()
                } label: {
                    Text("시작하기")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.top, 8)
                
                Spacer(minLength: 20)
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 24)
        }
        .navigationTitle("퀴즈 풀기")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack { StartQuizView() }
}
