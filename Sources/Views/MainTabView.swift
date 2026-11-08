import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem { Label("Live", systemImage: "speedometer") }
            TripHistoryView()
                .tabItem { Label("History", systemImage: "map") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .tint(.cyan)
    }
}
