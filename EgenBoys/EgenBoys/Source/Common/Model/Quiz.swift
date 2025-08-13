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
    @Relationship(deleteRule: .cascade) var questions: [Question]
    
    init(id: UUID = UUID(), title: String, explanation: String, category: QuizCategory, questions: [Question], imageURL: URL?, videoURL: URL?) {
        self.id = id
        self.title = title
        self.explanation = explanation
        self.category = category
        self.questions = questions
        self.imageURL = imageURL
        self.videoURL = videoURL
    }
}
