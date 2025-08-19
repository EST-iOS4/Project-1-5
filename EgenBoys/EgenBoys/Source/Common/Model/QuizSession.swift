//
//  QuizSession.swift
//  EgenBoys
//
//  Created by 이건준 on 8/19/25.
//

import Foundation
import SwiftData

@Model final class QuizSession {
    @Attribute(.unique) var id: UUID
    var title: String
    var startedAt: Date
    var endedAt: Date?
    var totalQuestions: Int
    var correctCount: Int
    var score: Int                // 0~100 (정답률/점수)
    
    @Relationship(deleteRule: .cascade, inverse: \Summary.session)
    var items: [Summary] = []

    init(
        id: UUID = UUID(),
        title: String,
        startedAt: Date = Date(),
        endedAt: Date? = nil,
        totalQuestions: Int = 0,
        correctCount: Int = 0,
        score: Int = 0
    ) {
        self.id = id
        self.title = title
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.totalQuestions = totalQuestions
        self.correctCount = correctCount
        self.score = score
    }
}

@Model final class Summary {
    @Attribute(.unique) var id: UUID
    var content: String
    var isCorrect: Bool

    // ⬇️ 추가: 세션 소속 + 생성 시각(선택)
    var createdAt: Date
    @Relationship var session: QuizSession?

    init(
        id: UUID = UUID(),
        content: String,
        isCorrect: Bool,
        createdAt: Date = Date(),
        session: QuizSession? = nil
    ) {
        self.id = id
        self.content = content
        self.isCorrect = isCorrect
        self.createdAt = createdAt
        self.session = session
    }
}
