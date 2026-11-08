import SwiftUI

@main
struct SupremeIoniq6LoggerApp: App {
    @StateObject private var tripViewModel = TripViewModel()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(tripViewModel)
                .preferredColorScheme(.dark)
        }
    }
}
