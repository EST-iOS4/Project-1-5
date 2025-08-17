//
//  QuizPlayView.swift
//  EgenBoys
//
//  Created by 정수안 on 8/11/25.
//

import SwiftUI

struct QuizPlayView: View {
    var body: some View {
        NavigationStack {
            StartQuizView()   // ✅ 내부에서 SwiftData로 퀴즈 선택
        }
    }
}

#Preview {
    QuizPlayView()
}

