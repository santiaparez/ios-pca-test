import SwiftUI
import SwiftData

struct StatsView: View {
    @Query private var questions: [Question]

    var totalAttempts: Int {
        questions.reduce(0) { $0 + $1.totalAttempts }
    }

    var totalCorrect: Int {
        questions.reduce(0) { $0 + $1.correctCount }
    }

    var globalAccuracy: Double {
        guard totalAttempts > 0 else { return 0 }
        return Double(totalCorrect) / Double(totalAttempts)
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Resumen") {
                    LabeledContent("Acierto global", value: String(format: "%.0f%%", globalAccuracy * 100))
                    LabeledContent("Intentos", value: "\(totalAttempts)")
                }

                Section("Más falladas") {
                    ForEach(mostFailedQuestions) { question in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(question.prompt)
                                .font(.headline)
                            Text("Fallos: \(question.incorrectCount)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Estadísticas")
        }
    }

    private var mostFailedQuestions: [Question] {
        questions.sorted { $0.incorrectCount > $1.incorrectCount }.prefix(5).map { $0 }
    }
}
