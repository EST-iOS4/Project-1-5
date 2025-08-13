//
//  Question.swift
//  EgenBoys
//
//  Created by 이건준 on 8/13/25.
//

import Foundation
import SwiftData

@Model final class Question {
    @Attribute(.unique) var id: UUID
    var content: String
    var isCorrect: Bool
    
    init(id: UUID = UUID(), content: String, isCorrect: Bool) {
        self.id = id
        self.content = content
        self.isCorrect = isCorrect
    }
}
