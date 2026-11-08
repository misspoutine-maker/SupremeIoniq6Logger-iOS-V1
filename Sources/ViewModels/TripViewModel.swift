import Foundation
import CoreLocation
import Combine

@MainActor
final class TripViewModel: ObservableObject {
    @Published private(set) var activeTrip: Trip?
    @Published private(set) var currentSpeedKph: Double = 0
    @Published private(set) var currentAltitudeMeters: Double = 0
    @Published private(set) var statusMessage = "GPS ready"
    @Published private(set) var isWaitingForGPS = false

    @Published var store = TripStore()
    let locationService = LocationService()

    private var previousAcceptedLocation: CLLocation?
    private var pendingTripStart = false
    private let geocoder = CLGeocoder()

    init() {
        locationService.onLocation = { [weak self] location in
            self?.receive(location)
        }
    }

    var trips: [Trip] { store.trips }

    func startTrip() {
        guard activeTrip == nil, !pendingTripStart else { return }
        pendingTripStart = true
        isWaitingForGPS = true
        statusMessage = "Waiting for GPS location…"
        locationService.start()

        if let location = locationService.latestLocation {
            beginTrip(at: location)
        }
    }

    func endTrip() {
        guard var trip = activeTrip else { return }
        trip.endDate = Date()
        if let location = locationService.latestLocation {
            trip.endPlace = placeDescription(for: location)
            appendFinalPoint(location, to: &trip)
        }
        store.update(trip)
        activeTrip = nil
        pendingTripStart = false
        isWaitingForGPS = false
        previousAcceptedLocation = nil
        statusMessage = "Trip saved"
        locationService.stop()
    }

    func deleteTrip(_ trip: Trip) {
        store.delete(id: trip.id)
    }

    func exportCSV() -> URL? {
        let header = "Date,Start,End,Distance km,Duration minutes,Average km/h,Maximum km/h\n"
        let rows = store.trips.map { trip in
            let end = trip.endDate?.formatted(date: .numeric, time: .shortened) ?? "In progress"
            let start = trip.startPlace.replacingOccurrences(of: "\"", with: "\"\"")
            let endPlace = (trip.endPlace ?? "").replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(trip.startDate.formatted(date: .numeric, time: .shortened))\",\"\"\(start)\"\",\"\"\(endPlace)\"\",\(String(format: "%.2f", trip.distanceKilometers)),\(String(format: "%.1f", trip.duration / 60)),\(String(format: "%.1f", trip.averageSpeedKph)),\(String(format: "%.1f", trip.maximumSpeedMetersPerSecond * 3.6))"
        }.joined(separator: "\n")
        let contents = header + rows
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("SupremeIoniq6Logger-Trips.csv")
        do {
            try contents.data(using: .utf8)?.write(to: url, options: .atomic)
            return url
        } catch {
            statusMessage = "Could not create CSV export."
            return nil
        }
    }

    private func receive(_ location: CLLocation) {
        currentSpeedKph = max(0, location.speed) * 3.6
        currentAltitudeMeters = location.altitude

        if pendingTripStart && activeTrip == nil {
            beginTrip(at: location)
            return
        }

        guard var trip = activeTrip else { return }
        appendFinalPoint(location, to: &trip)
        activeTrip = trip
        store.update(trip)
    }

    private func beginTrip(at location: CLLocation) {
        guard location.horizontalAccuracy >= 0, location.horizontalAccuracy <= 100 else { return }
        let point = makePoint(location)
        let trip = Trip(
            startDate: Date(),
            startPlace: "GPS location",
            route: [point],
            distanceMeters: 0,
            maximumSpeedMetersPerSecond: max(0, location.speed)
        )
        activeTrip = trip
        store.insert(trip)
        previousAcceptedLocation = location
        pendingTripStart = false
        isWaitingForGPS = false
        statusMessage = "Trip recording"
        reverseGeocode(location) { [weak self] place in
            guard let self, var current = self.activeTrip else { return }
            current.startPlace = place
            self.activeTrip = current
            self.store.update(current)
        }
    }

    private func appendFinalPoint(_ location: CLLocation, to trip: inout Trip) {
        guard location.horizontalAccuracy >= 0, location.horizontalAccuracy <= 50 else { return }
        let previous = previousAcceptedLocation
        if let previous {
            let delta = location.timestamp.timeIntervalSince(previous.timestamp)
            let segment = location.distance(from: previous)
            // Reject GPS jumps and stale samples that can inflate distance.
            if delta > 0 && delta < 120 && segment < 1000 && (location.speed >= 0 || segment < 30) {
                trip.distanceMeters += segment
            }
        }
        trip.maximumSpeedMetersPerSecond = max(trip.maximumSpeedMetersPerSecond, max(0, location.speed))
        if trip.route.last?.timestamp != location.timestamp {
            trip.route.append(makePoint(location))
        }
        previousAcceptedLocation = location
    }

    private func makePoint(_ location: CLLocation) -> RoutePoint {
        RoutePoint(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            timestamp: location.timestamp,
            speedMetersPerSecond: max(0, location.speed),
            altitudeMeters: location.altitude,
            horizontalAccuracy: location.horizontalAccuracy
        )
    }

    private func placeDescription(for location: CLLocation) -> String {
        "\(location.coordinate.latitude.formatted(.number.precision(.fractionLength(5)))), \(location.coordinate.longitude.formatted(.number.precision(.fractionLength(5))))"
    }

    private func reverseGeocode(_ location: CLLocation, completion: @escaping (String) -> Void) {
        geocoder.reverseGeocodeLocation(location) { placemarks, _ in
            let placemark = placemarks?.first
            let parts = [placemark?.locality, placemark?.administrativeArea, placemark?.country].compactMap { $0 }
            completion(parts.isEmpty ? self.placeDescription(for: location) : parts.joined(separator: ", "))
        }
    }
}
