import SwiftUI

struct QuestionEditorView: View {
    @Binding var question: Question
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Enunciado") {
                    TextField("Pregunta", text: $question.prompt, axis: .vertical)
                }

                Section("Opciones") {
                    ForEach($question.choices) { $choice in
                        HStack {
                            Text(choice.key)
                                .frame(width: 24)
                            TextField("Texto", text: $choice.text, axis: .vertical)
                        }
                    }
                }

                Section("Respuesta correcta") {
                    Picker("Respuesta", selection: $question.answerKey) {
                        Text("Sin definir").tag(String?.none)
                        ForEach(question.choices) { choice in
                            Text(choice.key).tag(String?.some(choice.key))
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Explicación") {
                    TextField("Explicación", text: Binding(
                        get: { question.explanation ?? "" },
                        set: { question.explanation = $0.isEmpty ? nil : $0 }
                    ), axis: .vertical)
                }
            }
            .navigationTitle("Editar pregunta")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo") {
                        dismiss()
                    }
                }
            }
        }
    }
}
