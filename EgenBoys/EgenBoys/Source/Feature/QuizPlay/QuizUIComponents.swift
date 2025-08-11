//
//  QuizUIComponents.swift
//  EgenBoys
//
//  Created by 정수안 on 8/11/25.
//

import SwiftUI

/// 등록 화면 톤과 맞춰 놓기
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

/// 등록 화면 우측 체크박스 톤을 흉내 낸 옵션 셀
struct CheckboxRow: View {
    let index: Int
    let text: String
    let isSelected: Bool
    
    var body: some View {
        HStack {
            Text("\(index). \(text)")
                .frame(maxWidth: .infinity, alignment: .leading)
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(isSelected ? Color.blue : Color.secondary.opacity(0.35), lineWidth: 2)
                    .frame(width: 26, height: 26)
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                }
            }
        }
        .padding(12)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
