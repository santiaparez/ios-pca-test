import Foundation
import SwiftData

@MainActor
final class ReviewViewModel: ObservableObject {
    @Published var queue: [Question] = []
    @Published var currentIndex: Int = 0

    func buildQueue(from questions: [Question]) {
        let now = Date()
        let due = questions.filter { question in
            guard let next = question.nextReviewAt else { return true }
            return next <= now
        }
        queue = due.sorted { ($0.nextReviewAt ?? .distantPast) < ($1.nextReviewAt ?? .distantPast) }
        currentIndex = 0
    }

    func markAnswer(correct: Bool) {
        guard currentIndex < queue.count else { return }
        let question = queue[currentIndex]
        let nextInterval = calculateInterval(for: question, correct: correct)
        question.intervalDays = nextInterval
        question.nextReviewAt = Calendar.current.date(byAdding: .day, value: nextInterval, to: Date())
        if correct {
            question.correctCount += 1
        } else {
            question.incorrectCount += 1
        }
        moveNext()
    }

    private func calculateInterval(for question: Question, correct: Bool) -> Int {
        if correct {
            return max(1, question.intervalDays == 0 ? 1 : question.intervalDays * 2)
        }
        return 1
    }

    private func moveNext() {
        if currentIndex + 1 < queue.count {
            currentIndex += 1
        }
    }
}
