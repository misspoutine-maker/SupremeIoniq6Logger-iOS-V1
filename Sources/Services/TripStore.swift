import Foundation
import Combine

@MainActor
final class TripStore: ObservableObject {
    @Published private(set) var trips: [Trip] = []

    private let fileURL: URL

    init() {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        fileURL = documents.appendingPathComponent("trips-v1.json")
        load()
    }

    func insert(_ trip: Trip) {
        trips.insert(trip, at: 0)
        save()
    }

    func update(_ trip: Trip) {
        guard let index = trips.firstIndex(where: { $0.id == trip.id }) else { return }
        trips[index] = trip
        save()
    }

    func delete(at offsets: IndexSet) {
        trips.remove(atOffsets: offsets)
        save()
    }

    func delete(id: UUID) {
        trips.removeAll { $0.id == id }
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let decoded = try? decoder.decode([Trip].self, from: data) {
            trips = decoded.sorted { $0.startDate > $1.startDate }
        }
    }

    private func save() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(trips) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
