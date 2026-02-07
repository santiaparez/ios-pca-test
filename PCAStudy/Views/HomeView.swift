import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var questions: [Question]
    @StateObject private var viewModel = ImportViewModel()
    @State private var isFileImporterPresented = false
    @State private var importType: ImportType = .pdf

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("PCA Study")
                                .font(.title2.bold())
                            Text("Banco actual: \(questions.count) preguntas")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }

                    NavigationLink {
                        ReviewView()
                    } label: {
                        HomeActionCard(title: "Continuar", subtitle: "Retomar repaso pendiente", systemImage: "play.circle")
                    }

                    NavigationLink {
                        QuizView()
                    } label: {
                        HomeActionCard(title: "Quiz rápido", subtitle: "Aleatorio de 10 preguntas", systemImage: "bolt")
                    }

                    NavigationLink {
                        FlashView()
                    } label: {
                        HomeActionCard(title: "Flash", subtitle: "Mostrar y revelar respuestas", systemImage: "rectangle.on.rectangle")
                    }

                    NavigationLink {
                        ExamView()
                    } label: {
                        HomeActionCard(title: "Examen", subtitle: "Simulación con tiempo", systemImage: "timer")
                    }

                    VStack(spacing: 12) {
                        Button {
                            importType = .pdf
                            isFileImporterPresented = true
                        } label: {
                            Label("Importar PDF", systemImage: "doc.richtext")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)

                        Button {
                            importType = .json
                            isFileImporterPresented = true
                        } label: {
                            Label("Importar JSON", systemImage: "tray.and.arrow.down")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.top, 8)

                    if viewModel.isImporting {
                        ProgressView(viewModel.progressText.isEmpty ? "Importando..." : viewModel.progressText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    if let summary = viewModel.summary {
                        ImportSummaryView(summary: summary)
                    }

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.footnote)
                    }
                }
                .padding()
            }
            .navigationTitle("Inicio")
        }
        .fileImporter(
            isPresented: $isFileImporterPresented,
            allowedContentTypes: importType == .pdf ? [.pdf] : [.json],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                Task {
                    if importType == .pdf {
                        await viewModel.importPDF(from: url, modelContext: modelContext)
                    } else {
                        viewModel.importJSON(from: url, modelContext: modelContext)
                    }
                }
            case .failure(let error):
                viewModel.errorMessage = error.localizedDescription
            }
        }
    }
}

private enum ImportType {
    case pdf
    case json
}

struct HomeActionCard: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundStyle(.tint)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

struct ImportSummaryView: View {
    let summary: ImportSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Resumen de importación")
                .font(.headline)
            Text("Total: \(summary.total)")
            Text("Con respuesta detectada: \(summary.withAnswer)")
            Text("Requieren revisión: \(summary.needsReview)")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGroupedBackground))
        )
    }
}
