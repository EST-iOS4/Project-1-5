//
//  QuizSummaryView.swift
//  EgenBoys
//
//  Created by 정수안 on 8/11/25.
//

import SwiftUI

struct QuizSummaryView: View {
    let total: Int
    let correct: Int
    var onClose: () -> Void
    
    var accuracy: String {
        guard total > 0 else { return "0%" }
        return String(format: "%.0f%%", (Double(correct) / Double(total)) * 100)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("퀴즈 요약")
                    .font(.title3.bold())
                
                VStack(spacing: 12) {
                    HStack {
                        Text("총 문제")
                        Spacer()
                        Text("\(total)")
                    }
                    HStack {
                        Text("맞힌 개수")
                        Spacer()
                        Text("\(correct)")
                            .foregroundStyle(.blue)
                            .fontWeight(.semibold)
                    }
                    HStack {
                        Text("정답률")
                        Spacer()
                        Text(accuracy)
                    }
                }
                .padding(16)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
                
                Button {
                    onClose()
                } label: {
                    Text("닫기")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, 24)
        }
    }
}

#Preview {
    QuizSummaryView(total: 10, correct: 7, onClose: {})
}
import SwiftUI

struct QuizSummaryScoreView: View {
    let percent: Int            // 0 ~ 100
    var onClose: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("퀴즈 요약")
                    .font(.title3.bold())

                VStack(spacing: 12) {
                    HStack {
                        Text("정답률")
                        Spacer()
                        Text("\(percent)%")
                            .fontWeight(.semibold)
                            .foregroundStyle(.blue)
                    }
                    // 필요하면 추가 지표도 표시 가능
                    // HStack { Text("선택 수"); Spacer(); Text("\(selectedCount)개") }
                }
                .padding(16)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)

                Button {
                    onClose()
                } label: {
                    Text("닫기")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top, 24)
        }
    }
}
