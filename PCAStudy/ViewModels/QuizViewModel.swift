import Foundation
import SwiftData

@MainActor
final class QuizViewModel: ObservableObject {
    @Published var questions: [Question] = []
    @Published var currentIndex: Int = 0
    @Published var selectedKey: String?
    @Published var showFeedback: Bool = true

    func loadQuestions(from questions: [Question], limit: Int?) {
        var shuffled = questions.shuffled()
        if let limit {
            shuffled = Array(shuffled.prefix(limit))
        }
        self.questions = shuffled
        currentIndex = 0
        selectedKey = nil
    }

    func selectAnswer(_ key: String) {
        selectedKey = key
    }

    func moveNext() {
        guard currentIndex + 1 < questions.count else { return }
        currentIndex += 1
        selectedKey = nil
    }
}
