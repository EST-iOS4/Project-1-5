//
//  QuizItemView.swift
//  EgenBoys
//
//  Created by 이건준 on 8/11/25.
//

import SwiftUI

struct QuizItemView: View {
    let item: Quiz
    
    var body: some View {
        HStack(spacing: 12) {
            EBImageView(url: item.imageURL)
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .shadow(radius: 10)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Text(item.explanation)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
    }
}
