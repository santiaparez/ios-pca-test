import Foundation
import PDFKit
import SwiftData

struct ImportSummary {
    let total: Int
    let withAnswer: Int
    let needsReview: Int
}

struct JSONQuestionBank: Codable {
    let title: String
    let questions: [JSONQuestion]
}

struct JSONQuestion: Codable {
    let id: String
    let category: String
    let prompt: String
    let choices: [Choice]
    let answerKey: String?
    let explanation: String?
}

@MainActor
final class QuestionImportService {
    private let ocrService = OCRService()
    private let parser = QuestionParser()

    func importPDF(url: URL, modelContext: ModelContext, progress: @escaping (Int, Int) -> Void) async throws -> ImportSummary {
        guard let document = PDFDocument(url: url) else {
            throw ImportError.invalidPDF
        }
        let ocrResults = try await ocrService.recognizeText(from: document, progress: progress)
        var imported: [Question] = []

        for result in ocrResults {
            let parsed = parser.parse(text: result.text, pageNumber: result.pageNumber)
            for question in parsed {
                let model = Question(
                    category: question.category,
                    prompt: question.prompt,
                    choices: question.choices,
                    answerKey: question.answerKey,
                    explanation: question.explanation,
                    source: .pdf,
                    pageNumber: question.pageNumber
                )
                imported.append(model)
                modelContext.insert(model)
            }
        }

        try modelContext.save()
        return summarize(imported)
    }

    func importJSON(url: URL, modelContext: ModelContext) throws -> ImportSummary {
        let data = try Data(contentsOf: url)
        let bank = try JSONDecoder().decode(JSONQuestionBank.self, from: data)
        let questions = bank.questions.map { json in
            Question(
                id: json.id,
                category: json.category,
                prompt: json.prompt,
                choices: json.choices,
                answerKey: json.answerKey,
                explanation: json.explanation,
                source: .json,
                pageNumber: nil
            )
        }
        questions.forEach { modelContext.insert($0) }
        try modelContext.save()
        return summarize(questions)
    }

    private func summarize(_ questions: [Question]) -> ImportSummary {
        let withAnswer = questions.filter { $0.answerKey != nil }.count
        let needsReview = questions.count - withAnswer
        return ImportSummary(total: questions.count, withAnswer: withAnswer, needsReview: needsReview)
    }
}

enum ImportError: LocalizedError {
    case invalidPDF

    var errorDescription: String? {
        switch self {
        case .invalidPDF:
            return "No se pudo abrir el PDF."
        }
    }
}
