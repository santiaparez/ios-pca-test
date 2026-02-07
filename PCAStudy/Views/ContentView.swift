import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Inicio", systemImage: "house")
                }
            CategoriesView()
                .tabItem {
                    Label("Categorías", systemImage: "list.bullet.rectangle")
                }
            ReviewView()
                .tabItem {
                    Label("Repaso", systemImage: "clock.arrow.circlepath")
                }
            StatsView()
                .tabItem {
                    Label("Estadísticas", systemImage: "chart.bar")
                }
            SettingsView()
                .tabItem {
                    Label("Ajustes", systemImage: "gearshape")
                }
        }
    }
}
