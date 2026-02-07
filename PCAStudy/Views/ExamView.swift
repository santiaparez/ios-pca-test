import SwiftUI
import SwiftData

struct ExamView: View {
    @Query private var questions: [Question]
    @State private var examQuestions: [Question] = []
    @State private var currentIndex = 0
    @State private var selectedKey: String?
    @State private var score = 0
    @State private var remainingSeconds = 1800
    @State private var timer: Timer?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            if examQuestions.isEmpty {
                ContentUnavailableView("Sin preguntas", systemImage: "doc.text")
            } else if currentIndex >= examQuestions.count {
                ExamSummaryView(score: score, total: examQuestions.count)
            } else {
                let question = examQuestions[currentIndex]
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Tiempo: \(formattedTime)")
                            .font(.headline)
                        Spacer()
                        Text("Puntaje: \(score)")
                            .font(.headline)
                    }

                    QuestionCard(question: question, selectedKey: $selectedKey)

                    Button("Registrar respuesta") {
                        evaluate(question)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(selectedKey == nil)
                }
                .padding()
            }
        }
        .navigationTitle("Examen")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cerrar") { dismiss() }
            }
        }
        .onAppear {
            startExam()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    private var formattedTime: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func startExam() {
        examQuestions = Array(questions.shuffled().prefix(30))
        currentIndex = 0
        score = 0
        selectedKey = nil
        remainingSeconds = 1800
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if remainingSeconds > 0 {
                remainingSeconds -= 1
            }
        }
    }

    private func evaluate(_ question: Question) {
        if selectedKey == question.answerKey {
            score += 1
            question.correctCount += 1
        } else {
            question.incorrectCount += 1
        }
        selectedKey = nil
        currentIndex += 1
    }
}

struct ExamSummaryView: View {
    let score: Int
    let total: Int

    var body: some View {
        VStack(spacing: 12) {
            Text("Examen finalizado")
                .font(.title2.bold())
            Text("Puntaje: \(score) / \(total)")
                .font(.headline)
        }
        .padding()
    }
}
