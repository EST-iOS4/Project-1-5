//
//  QuizUIComponents.swift
//  EgenBoys
//
//  Created by 정수안 on 8/11/25.
//

import SwiftUI

// 그대로 쓰던 섹션 카드
struct SectionCard<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content
    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title; self.content = content()
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.footnote).foregroundStyle(.secondary).padding(.horizontal, 4)
            VStack(spacing: 0) { content.padding(14) }
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

// ✅ 새로 추가되는 피드백 상태
enum ChoiceFeedback { case correct, wrong, dimmed }

// ✅ 체크박스(피드백 지원 버전) — 이걸로 교체!
struct CheckboxRow: View {
    let index: Int
    let text: String
    let isSelected: Bool
    var feedback: ChoiceFeedback? = nil   // ← 추가된 파라미터(기본값 있어서 기존 화면 영향 X)

    private var stroke: Color {
        switch feedback {
        case .correct: return .green
        case .wrong:   return .red
        case .dimmed:  return Color.secondary.opacity(0.25)
        case .none:    return isSelected ? .blue : Color.secondary.opacity(0.35)
        }
    }
    private var bg: Color {
        switch feedback {
        case .correct: return Color.green.opacity(0.12)
        case .wrong:   return Color.red.opacity(0.12)
        case .dimmed:  return Color.secondary.opacity(0.06)
        case .none:    return Color(.systemBackground)
        }
    }
    private var txt: Color { feedback == .dimmed ? .secondary : .primary }

    var body: some View {
        HStack {
            Text("\(index). \(text)").foregroundStyle(txt).frame(maxWidth: .infinity, alignment: .leading)
            ZStack {
                RoundedRectangle(cornerRadius: 6).strokeBorder(stroke, lineWidth: 2).frame(width: 26, height: 26)
                if isSelected {
                    Image(systemName: "checkmark").font(.system(size: 14, weight: .bold)).foregroundStyle(stroke)
                }
            }
        }
        .padding(12)
        .background(bg)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
