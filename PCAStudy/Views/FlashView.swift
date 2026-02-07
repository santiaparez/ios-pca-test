import SwiftUI
import SwiftData

struct FlashView: View {
    @Query private var questions: [Question]
    @State private var index = 0
    @State private var showAnswer = false

    var body: some View {
        VStack {
            if questions.isEmpty {
                ContentUnavailableView("Sin preguntas", systemImage: "doc.text")
            } else {
                let question = questions[index]
                VStack(alignment: .leading, spacing: 16) {
                    Text(question.prompt)
                        .font(.title3)

                    if showAnswer {
                        if let answerKey = question.answerKey,
                           let choice = question.choices.first(where: { $0.key == answerKey }) {
                            Text("Respuesta: \(answerKey). \(choice.text)")
                                .font(.headline)
                        }
                        HStack {
                            Button("La sé") {
                                question.correctCount += 1
                                advance()
                            }
                            .buttonStyle(.borderedProminent)

                            Button("No la sé") {
                                question.incorrectCount += 1
                                advance()
                            }
                            .buttonStyle(.bordered)
                        }
                    } else {
                        Button("Revelar respuesta") {
                            showAnswer = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Flash")
    }

    private func advance() {
        showAnswer = false
        index = (index + 1) % max(questions.count, 1)
    }
}
