//
//  Quiz.swift
//  EgenBoys
//
//  Created by 이건준 on 8/12/25.
//

import Foundation
import SwiftData

@Model final class Quiz {
    @Attribute(.unique) var id: UUID
    var title: String
    var explanation: String
    var category: QuizCategory
    var imageURL: URL?
    var videoURL: URL?
    var difficultty: Difficulty
    @Relationship(deleteRule: .cascade) var questions: [Question]
    
    init(id: UUID = UUID(), title: String, explanation: String, category: QuizCategory, questions: [Question], imageURL: URL?, videoURL: URL?, difficultty: Difficulty) {
        self.id = id
        self.title = title
        self.explanation = explanation
        self.category = category
        self.questions = questions
        self.imageURL = imageURL
        self.videoURL = videoURL
        self.difficultty = difficultty
    }
}

enum QuizCategory: String, Codable, CaseIterable {
    case all = "모든 퀴즈"
    case ios = "iOS"
    case design = "Design"
    case cs = "CS"
}

enum Difficulty: String, Codable, CaseIterable {
    case easy = "쉬움"
    case medium = "보통"
    case hard = "어려움"
}
