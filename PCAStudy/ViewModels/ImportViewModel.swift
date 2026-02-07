import Foundation
import SwiftData

@MainActor
final class ImportViewModel: ObservableObject {
    @Published var isImporting = false
    @Published var progressText: String = ""
    @Published var summary: ImportSummary?
    @Published var errorMessage: String?

    private let service = QuestionImportService()

    func importPDF(from url: URL, modelContext: ModelContext) async {
        isImporting = true
        errorMessage = nil
        summary = nil
        progressText = ""
        do {
            let summary = try await service.importPDF(url: url, modelContext: modelContext) { current, total in
                self.progressText = "Procesando página \(current) de \(total)"
            }
            self.summary = summary
        } catch {
            errorMessage = error.localizedDescription
        }
        isImporting = false
    }

    func importJSON(from url: URL, modelContext: ModelContext) {
        isImporting = true
        errorMessage = nil
        summary = nil
        progressText = ""
        do {
            let summary = try service.importJSON(url: url, modelContext: modelContext)
            self.summary = summary
        } catch {
            errorMessage = error.localizedDescription
        }
        isImporting = false
    }
}
