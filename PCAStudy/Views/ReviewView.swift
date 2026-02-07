import SwiftUI
import SwiftData

struct ReviewView: View {
    @Query private var questions: [Question]
    @StateObject private var viewModel = ReviewViewModel()
    @State private var revealAnswer = false

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.queue.isEmpty {
                    ContentUnavailableView("Sin repaso pendiente", systemImage: "checkmark.circle")
                } else {
                    let current = viewModel.queue[viewModel.currentIndex]
                    VStack(alignment: .leading, spacing: 16) {
                        Text(current.prompt)
                            .font(.title3)

                        if revealAnswer {
                            if let answerKey = current.answerKey,
                               let choice = current.choices.first(where: { $0.key == answerKey }) {
                                Text("Respuesta: \(answerKey). \(choice.text)")
                                    .font(.headline)
                            } else {
                                Text("Respuesta no definida. Edita la pregunta para asignarla.")
                                    .foregroundStyle(.secondary)
                            }

                            HStack {
                                Button("La sé") {
                                    viewModel.markAnswer(correct: true)
                                    revealAnswer = false
                                }
                                .buttonStyle(.borderedProminent)

                                Button("No la sé") {
                                    viewModel.markAnswer(correct: false)
                                    revealAnswer = false
                                }
                                .buttonStyle(.bordered)
                            }
                        } else {
                            Button("Mostrar respuesta") {
                                revealAnswer = true
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Repaso")
            .onAppear {
                viewModel.buildQueue(from: questions)
            }
        }
    }
}
