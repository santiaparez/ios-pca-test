import Foundation

struct ParsedQuestion {
    let category: String
    let prompt: String
    let choices: [Choice]
    let answerKey: String?
    let explanation: String?
    let pageNumber: Int?
}

final class QuestionParser {
    func parse(text: String, pageNumber: Int?) -> [ParsedQuestion] {
        let normalized = normalize(text)
        let lines = normalized.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)

        var questions: [ParsedQuestion] = []
        var currentPrompt: [String] = []
        var currentChoices: [Choice] = []
        var currentAnswerKey: String?
        var currentExplanation: [String] = []
        var currentCategory = "General"
        var parsingExplanation = false

        func commitQuestion() {
            guard !currentPrompt.isEmpty else { return }
            let promptText = currentPrompt.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
            let explanationText = currentExplanation.isEmpty ? nil : currentExplanation.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
            let question = ParsedQuestion(
                category: currentCategory,
                prompt: promptText,
                choices: currentChoices,
                answerKey: currentAnswerKey,
                explanation: explanationText,
                pageNumber: pageNumber
            )
            questions.append(question)
            currentPrompt.removeAll()
            currentChoices.removeAll()
            currentAnswerKey = nil
            currentExplanation.removeAll()
            parsingExplanation = false
        }

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty { continue }

            if let category = detectCategory(from: trimmed) {
                currentCategory = category
                continue
            }

            if isQuestionHeader(trimmed) {
                commitQuestion()
                currentPrompt.append(stripQuestionHeader(trimmed))
                continue
            }

            if let choice = parseChoice(trimmed) {
                parsingExplanation = false
                currentChoices.append(choice)
                continue
            }

            if let answerKey = parseAnswerKey(trimmed) {
                currentAnswerKey = answerKey
                continue
            }

            if isExplanationStart(trimmed) {
                parsingExplanation = true
                let explanationSeed = trimmed.replacingOccurrences(of: "Explicación", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                if !explanationSeed.isEmpty {
                    currentExplanation.append(explanationSeed)
                }
                continue
            }

            if parsingExplanation {
                currentExplanation.append(trimmed)
            } else {
                currentPrompt.append(trimmed)
            }
        }

        commitQuestion()
        return questions
    }

    private func normalize(_ text: String) -> String {
        let cleaned = text
            .replacingOccurrences(of: "\t", with: " ")
            .replacingOccurrences(of: "  +", with: " ", options: .regularExpression)
        return cleaned
    }

    private func isQuestionHeader(_ line: String) -> Bool {
        let pattern = "^\\d+[-\\.]\\s"
        return line.range(of: pattern, options: .regularExpression) != nil
    }

    private func stripQuestionHeader(_ line: String) -> String {
        let pattern = "^\\d+[-\\.]\\s"
        return line.replacingOccurrences(of: pattern, with: "", options: .regularExpression)
    }

    private func parseChoice(_ line: String) -> Choice? {
        let pattern = "^([A-C])\\.\\s+(.*)$"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(location: 0, length: line.utf16.count)
        guard let match = regex.firstMatch(in: line, options: [], range: range) else { return nil }
        guard let keyRange = Range(match.range(at: 1), in: line),
              let textRange = Range(match.range(at: 2), in: line) else { return nil }
        let key = String(line[keyRange])
        let text = String(line[textRange]).trimmingCharacters(in: .whitespacesAndNewlines)
        return Choice(key: key, text: text)
    }

    private func parseAnswerKey(_ line: String) -> String? {
        let patterns = [
            "Respuesta:\\s*([A-C])",
            "La respuesta\\s*\\(?([A-C])\\)?"
        ]
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) {
                let range = NSRange(location: 0, length: line.utf16.count)
                if let match = regex.firstMatch(in: line, options: [], range: range),
                   let keyRange = Range(match.range(at: 1), in: line) {
                    return String(line[keyRange]).uppercased()
                }
            }
        }
        return nil
    }

    private func detectCategory(from line: String) -> String? {
        let pattern = "^Categoria:\\s*(.*)$"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return nil }
        let range = NSRange(location: 0, length: line.utf16.count)
        guard let match = regex.firstMatch(in: line, options: [], range: range),
              let textRange = Range(match.range(at: 1), in: line) else { return nil }
        let text = String(line[textRange]).trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty ? nil : text
    }

    private func isExplanationStart(_ line: String) -> Bool {
        line.lowercased().hasPrefix("explicación")
    }
}
