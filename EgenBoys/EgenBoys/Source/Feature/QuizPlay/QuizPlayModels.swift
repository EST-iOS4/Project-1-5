//
//  QuizPlayModels.swift
//  EgenBoys
//
//  Created by 정수안 on 8/12/25.
//
// QuizPlayModels.swift
import Foundation

/// 세션(풀이) 화면에서 쓰는 가벼운 모델
/// - answerIndices: 0-based 인덱스 (복수 정답 가능)
struct QuizQuestion: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let options: [String]
    let answerIndices: Set<Int>

    init(text: String, options: [String], answerIndices: Set<Int>) {
        self.text = text
        self.options = options
        self.answerIndices = answerIndices
    }
}

// 미리보기/개발용 샘플
extension QuizQuestion {
    static let sample: [QuizQuestion] = [
        .init(text: "샘플1", options: ["1","2","3","4"], answerIndices: [1,3]),
        .init(text: "샘플2", options: ["A","B","C","D"], answerIndices: [0]),
        .init(text: "샘플3", options: ["가","나","다","라"], answerIndices: [2]),
        .init(text: "샘플4", options: ["봄","여름","가을","겨울"], answerIndices: [1,2]),
        .init(text: "샘플5", options: ["x","y","z","w"], answerIndices: [3]),
    ]
}

// -------- 어댑터(팀 데이터 → 세션 모델) --------
// 팀 모델 구조에 맞게 아래 두 개 중 하나(또는 둘 다)만 남겨 쓰세요.

// 1) 팀이 정답을 "인덱스 배열"로 줄 때
struct TeamQuestionIndex {
    let title: String
    let choices: [String]
    let correctIndexes: [Int]   // 0-based
}

extension Array where Element == TeamQuestionIndex {
    func toSessionQuestions() -> [QuizQuestion] {
        map { tq in
            QuizQuestion(
                text: tq.title,
                options: tq.choices,
                answerIndices: Set(tq.correctIndexes)
            )
        }
    }
}

// 2) 팀이 정답을 "텍스트 배열"로 줄 때
struct TeamQuestionText {
    let title: String
    let choices: [String]
    let correctTexts: [String]
}

extension Array where Element == TeamQuestionText {
    func toSessionQuestions() -> [QuizQuestion] {
        map { tq in
            let idxSet = Set(
                tq.choices.enumerated()
                    .compactMap { tq.correctTexts.contains($0.element) ? $0.offset : nil }
            )
            return QuizQuestion(
                text: tq.title,
                options: tq.choices,
                answerIndices: idxSet
            )
        }
    }
}

