import SwiftUI

struct QuestionView: View {
    @Binding var question: Question
    @State private var selectedKey: String?
    @State private var showEditor = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
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
                            .fill(backgroundColor(for: choice.key))
                    )
                }
                .buttonStyle(.plain)
            }

            if let answerKey = question.answerKey, let selectedKey {
                Text(answerKey == selectedKey ? "¡Correcto!" : "Respuesta incorrecta")
                    .foregroundStyle(answerKey == selectedKey ? .green : .red)
                if let explanation = question.explanation {
                    Text(explanation)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            } else if question.answerKey == nil {
                Text("Esta pregunta requiere revisión.")
                    .font(.footnote)
                    .foregroundStyle(.orange)
            }

            HStack {
                Button {
                    question.isFlagged.toggle()
                } label: {
                    Label(question.isFlagged ? "Marcada" : "Marcar", systemImage: question.isFlagged ? "bookmark.fill" : "bookmark")
                }
                .buttonStyle(.bordered)

                Button {
                    showEditor = true
                } label: {
                    Label("Editar", systemImage: "pencil")
                }
                .buttonStyle(.bordered)
                .disabled(question.answerKey != nil)
            }
        }
        .sheet(isPresented: $showEditor) {
            QuestionEditorView(question: $question)
        }
    }

    private func backgroundColor(for key: String) -> Color {
        guard let selectedKey else {
            return Color(.secondarySystemBackground)
        }
        if key == selectedKey {
            return Color.accentColor.opacity(0.2)
        }
        return Color(.secondarySystemBackground)
    }
}
