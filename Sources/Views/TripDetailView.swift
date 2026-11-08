import SwiftUI
import MapKit

struct TripDetailView: View {
    let trip: Trip

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 45.5017, longitude: -73.5673),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )

    var body: some View {
        List {
            Section("Trip") {
                detailRow("Started", trip.formattedStart)
                detailRow("Start", trip.startPlace)
                detailRow("End", trip.endPlace ?? (trip.isActive ? "In progress" : "Not recorded"))
                detailRow("Distance", String(format: "%.2f km", trip.distanceKilometers))
                detailRow("Duration", durationText(trip.duration))
                detailRow("Average speed", String(format: "%.1f km/h", trip.averageSpeedKph))
                detailRow("Maximum speed", String(format: "%.1f km/h", trip.maximumSpeedMetersPerSecond * 3.6))
            }

            if !trip.route.isEmpty {
                Section("Route preview") {
                    Map(coordinateRegion: $region, annotationItems: trip.route) { point in
                        MapMarker(coordinate: point.coordinate, tint: .cyan)
                    }
                    .frame(height: 260)
                    .onAppear {
                        if let first = trip.route.first {
                            region.center = first.coordinate
                        }
                    }
                }
            }
        }
        .navigationTitle("Trip Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func detailRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title).foregroundStyle(.secondary)
            Spacer()
            Text(value).multilineTextAlignment(.trailing)
        }
    }

    private func durationText(_ interval: TimeInterval) -> String {
        let minutes = max(0, Int(interval / 60))
        return "\(minutes / 60)h \(minutes % 60)m"
    }
}
