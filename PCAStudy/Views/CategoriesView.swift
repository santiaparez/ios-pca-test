import SwiftUI
import SwiftData

struct CategoriesView: View {
    @Query private var questions: [Question]

    var grouped: [String: [Question]] {
        Dictionary(grouping: questions, by: { $0.category })
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(grouped.keys.sorted(), id: \.self) { category in
                    let items = grouped[category] ?? []
                    NavigationLink(category) {
                        CategoryDetailView(category: category, questions: items)
                    }
                    .badge(items.count)
                }
            }
            .navigationTitle("Categorías")
        }
    }
}

struct CategoryDetailView: View {
    let category: String
    let questions: [Question]

    var body: some View {
        List {
            ForEach(questions) { question in
                VStack(alignment: .leading, spacing: 6) {
                    Text(question.prompt)
                        .font(.headline)
                    Text("Respuestas: \(question.answerKey ?? "Sin definir")")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle(category)
    }
}
