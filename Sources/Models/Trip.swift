import Foundation
import CoreLocation

struct RoutePoint: Codable, Identifiable {
    var id = UUID()
    let latitude: Double
    let longitude: Double
    let timestamp: Date
    let speedMetersPerSecond: Double
    let altitudeMeters: Double
    let horizontalAccuracy: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct Trip: Codable, Identifiable {
    var id = UUID()
    var startDate: Date
    var endDate: Date?
    var startPlace: String
    var endPlace: String?
    var route: [RoutePoint]
    var distanceMeters: Double
    var maximumSpeedMetersPerSecond: Double
    var notes: String = ""

    var duration: TimeInterval {
        (endDate ?? Date()).timeIntervalSince(startDate)
    }

    var averageSpeedKph: Double {
        guard duration > 0 else { return 0 }
        return distanceMeters / 1000 / (duration / 3600)
    }

    var distanceKilometers: Double { distanceMeters / 1000 }
    var isActive: Bool { endDate == nil }

    var formattedStart: String {
        startDate.formatted(date: .abbreviated, time: .shortened)
    }
}
