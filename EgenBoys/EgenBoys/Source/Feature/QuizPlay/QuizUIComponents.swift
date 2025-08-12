//
//  QuizUIComponents.swift
//  EgenBoys
//
//  Created by 정수안 on 8/11/25.
//

import SwiftUI

// 등록 화면 톤과 맞춘 카드 섹션 (기존과 동일)
struct SectionCard<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content
    
    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 4)
            VStack(spacing: 0) {
                content
                    .padding(14)
            }
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

// 보기 피드백 상태
enum ChoiceFeedback {
    case correct   // 정답 = 초록
    case wrong     // 선택한 오답 = 빨강
    case dimmed    // 정답 공개 후 나머지 = 흐리게
}

// 체크박스 옵션 셀 (피드백 색상 지원)
struct CheckboxRow: View {
    let index: Int
    let text: String
    let isSelected: Bool
    var feedback: ChoiceFeedback? = nil   // ← 새 파라미터(기본값 nil: 기존 화면 영향 없음)
    
    private var strokeColor: Color {
        switch feedback {
        case .correct: return .green
        case .wrong:   return .red
        case .dimmed:  return Color.secondary.opacity(0.25)
        case .none:    return isSelected ? .blue : Color.secondary.opacity(0.35)
        }
    }
    
    private var bgColor: Color {
        switch feedback {
        case .correct: return Color.green.opacity(0.12)
        case .wrong:   return Color.red.opacity(0.12)
        case .dimmed:  return Color.secondary.opacity(0.06)
        case .none:    return Color(.systemBackground)
        }
    }
    
    private var textColor: Color {
        switch feedback {
        case .dimmed: return .secondary
        default:      return .primary
        }
    }
    
    var body: some View {
        HStack {
            Text("\(index). \(text)")
                .foregroundStyle(textColor)
                .frame(maxWidth: .infinity, alignment: .leading)
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(strokeColor, lineWidth: 2)
                    .frame(width: 26, height: 26)
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(strokeColor)
                }
            }
        }
        .padding(12)
        .background(bgColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
