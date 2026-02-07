import SwiftUI

struct SettingsView: View {
    @AppStorage("showImmediateFeedback") private var showImmediateFeedback = true

    var body: some View {
        NavigationStack {
            Form {
                Section("Quiz") {
                    Toggle("Feedback inmediato", isOn: $showImmediateFeedback)
                }

                Section("Datos") {
                    LabeledContent("Exportar progreso", value: "Próximamente")
                }

                Section("Acerca de") {
                    Text("PCA Study es una app offline para estudiar bancos de preguntas a partir de PDFs escaneados o JSON.")
                        .font(.footnote)
                }
            }
            .navigationTitle("Ajustes")
        }
    }
}
