import SwiftUI
import CoreLocation

struct SettingsView: View {
    @EnvironmentObject private var model: TripViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Location") {
                    LabeledContent("Authorization", value: authorizationText)
                    Button("Allow background trip tracking") {
                        model.locationService.requestBackgroundPermission()
                    }
                    .disabled(model.locationService.authorizationStatus != .authorizedWhenInUse)
                    Text("For continuous trip recording while the iPhone is locked or another app is open, allow Always location access when iOS asks.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Application") {
                    LabeledContent("Version", value: "1.0 (Development)")
                    LabeledContent("Platform", value: "iPhone")
                    LabeledContent("Minimum iOS", value: "16.0")
                }

                Section("Coming next") {
                    Label("Vgate vLinker MC+ BLE connection", systemImage: "dot.radiowaves.left.and.right")
                    Label("IONIQ 6 battery and SOC data", systemImage: "battery.100percent")
                    Label("Charging sessions and costs", systemImage: "bolt.car")
                    Label("PDF trip reports", systemImage: "doc.richtext")
                }
            }
            .navigationTitle("Settings")
        }
    }

    private var authorizationText: String {
        switch model.locationService.authorizationStatus {
        case .authorizedAlways: return "Always"
        case .authorizedWhenInUse: return "While Using"
        case .denied: return "Denied"
        case .restricted: return "Restricted"
        case .notDetermined: return "Not requested"
        @unknown default: return "Unknown"
        }
    }
}
