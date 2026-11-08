import SwiftUI

struct TripHistoryView: View {
    @EnvironmentObject private var model: TripViewModel
    @State private var shareURL: URL?
    @State private var showingShare = false

    var body: some View {
        NavigationStack {
            Group {
                if model.trips.isEmpty {
                    ContentUnavailableView("No trips yet", systemImage: "car", description: Text("Your recorded trips will appear here."))
                } else {
                    List {
                        ForEach(model.trips) { trip in
                            NavigationLink {
                                TripDetailView(trip: trip)
                            } label: {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(trip.startPlace).font(.headline).lineLimit(1)
                                    Text(trip.formattedStart).font(.caption).foregroundStyle(.secondary)
                                    HStack {
                                        Label(String(format: "%.1f km", trip.distanceKilometers), systemImage: "point.topleft.down.to.point.bottomright.curvepath")
                                        Spacer()
                                        Text(trip.isActive ? "In progress" : durationText(trip.duration))
                                    }
                                    .font(.caption)
                                    .foregroundStyle(.cyan)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .onDelete(perform: model.store.delete)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Trip History")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        shareURL = model.exportCSV()
                        showingShare = shareURL != nil
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .accessibilityLabel("Export trips as CSV")
                }
            }
            .sheet(isPresented: $showingShare) {
                if let shareURL { ActivityView(items: [shareURL]) }
            }
        }
    }

    private func durationText(_ interval: TimeInterval) -> String {
        let minutes = max(0, Int(interval / 60))
        return "\(minutes / 60)h \(minutes % 60)m"
    }
}
