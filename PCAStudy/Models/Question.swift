import Foundation
import SwiftData

@Model
final class Question {
    @Attribute(.unique) var id: String
    var category: String
    var prompt: String
    @Attribute(.transformable) var choices: [Choice]
    var answerKey: String?
    var explanation: String?
    var source: QuestionSource
    var pageNumber: Int?

    var correctCount: Int
    var incorrectCount: Int
    var lastSeenAt: Date?
    var isFlagged: Bool
    var difficultyRating: Int

    var nextReviewAt: Date?
    var intervalDays: Int

    init(
        id: String = UUID().uuidString,
        category: String,
        prompt: String,
        choices: [Choice],
        answerKey: String? = nil,
        explanation: String? = nil,
        source: QuestionSource,
        pageNumber: Int? = nil
    ) {
        self.id = id
        self.category = category
        self.prompt = prompt
        self.choices = choices
        self.answerKey = answerKey
        self.explanation = explanation
        self.source = source
        self.pageNumber = pageNumber
        self.correctCount = 0
        self.incorrectCount = 0
        self.lastSeenAt = nil
        self.isFlagged = false
        self.difficultyRating = 0
        self.nextReviewAt = nil
        self.intervalDays = 0
    }

    var totalAttempts: Int {
        correctCount + incorrectCount
    }

    var accuracy: Double {
        guard totalAttempts > 0 else { return 0 }
        return Double(correctCount) / Double(totalAttempts)
    }
}

struct Choice: Codable, Hashable, Identifiable {
    var id: String { key }
    var key: String
    var text: String
}

enum QuestionSource: String, Codable {
    case pdf
    case json
}
