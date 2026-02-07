import SwiftUI
import SwiftData

struct QuizView: View {
    @Query private var questions: [Question]
    @StateObject private var viewModel = QuizViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            if viewModel.questions.isEmpty {
                ContentUnavailableView("Sin preguntas", systemImage: "doc.text")
            } else {
                let question = viewModel.questions[viewModel.currentIndex]
                VStack(alignment: .leading, spacing: 16) {
                    Text("Pregunta \(viewModel.currentIndex + 1) de \(viewModel.questions.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    QuestionCard(question: question, selectedKey: $viewModel.selectedKey)

                    if let selectedKey = viewModel.selectedKey, let answerKey = question.answerKey {
                        Text(selectedKey == answerKey ? "¡Correcto!" : "Incorrecto")
                            .foregroundStyle(selectedKey == answerKey ? .green : .red)
                        if let explanation = question.explanation {
                            Text(explanation)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Button("Siguiente") {
                        viewModel.moveNext()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.currentIndex + 1 >= viewModel.questions.count)
                }
                .padding()
            }
        }
        .navigationTitle("Quiz")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cerrar") { dismiss() }
            }
        }
        .onAppear {
            viewModel.loadQuestions(from: questions, limit: 10)
        }
    }
}

struct QuestionCard: View {
    let question: Question
    @Binding var selectedKey: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(question.prompt)
                .font(.title3)
            ForEach(question.choices) { choice in
                Button {
                    selectedKey = choice.key
                } label: {
                    HStack {
                        Text("\(choice.key). \(choice.text)")
                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedKey == choice.key ? Color.accentColor.opacity(0.2) : Color(.secondarySystemBackground))
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}
