import XCTest
@testable import SupremeIoniq6Logger

final class TripModelTests: XCTestCase {
    func testDistanceKilometersConversion() {
        let trip = Trip(
            startDate: Date(),
            startPlace: "Test",
            route: [],
            distanceMeters: 12500,
            maximumSpeedMetersPerSecond: 0
        )
        XCTAssertEqual(trip.distanceKilometers, 12.5, accuracy: 0.001)
    }

    func testAverageSpeedCalculation() {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let trip = Trip(
            startDate: start,
            endDate: start.addingTimeInterval(3600),
            startPlace: "Test",
            route: [],
            distanceMeters: 80_000,
            maximumSpeedMetersPerSecond: 30
        )
        XCTAssertEqual(trip.averageSpeedKph, 80, accuracy: 0.001)
    }
}
