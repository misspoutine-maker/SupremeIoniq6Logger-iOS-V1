import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var model: TripViewModel
    @State private var showEndConfirmation = false
    @State private var showLocationHelp = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    VStack(spacing: 4) {
                        Text("SUPREME")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .tracking(4)
                            .foregroundStyle(.cyan)
                        Text("IONIQ 6 LOGGER")
                            .font(.system(size: 22, weight: .heavy, design: .rounded))
                    }
                    .padding(.top, 12)

                    HStack(spacing: 12) {
                        SpeedGauge(title: "km/h", value: model.currentSpeedKph, unit: "km/h")
                        SpeedGauge(title: "mph", value: model.currentSpeedKph / 1.609344, unit: "mph")
                    }

                    HStack(spacing: 12) {
                        MetricTile(title: "ALTITUDE", value: "\(Int(model.currentAltitudeMeters))", unit: "m", icon: "mountain.2")
                        MetricTile(title: "DISTANCE", value: String(format: "%.1f", model.activeTrip?.distanceKilometers ?? 0), unit: "km", icon: "point.topleft.down.to.point.bottomright.curvepath")
                        MetricTile(title: "AVG SPEED", value: String(format: "%.0f", model.activeTrip?.averageSpeedKph ?? 0), unit: "km/h", icon: "gauge")
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Circle()
                                .fill(model.activeTrip == nil ? Color.orange : Color.green)
                                .frame(width: 9, height: 9)
                            Text(model.statusMessage)
                                .font(.subheadline.weight(.semibold))
                            Spacer()
                            if model.isWaitingForGPS {
                                ProgressView().tint(.cyan)
                            }
                        }
                        Text(model.activeTrip?.startPlace ?? "Ready to record your next drive")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        if let error = model.locationService.lastError {
                            Text(error).font(.caption).foregroundStyle(.red)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 16))

                    if model.activeTrip == nil {
                        Button {
                            model.startTrip()
                        } label: {
                            Label("START TRIP", systemImage: "play.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 17)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        .disabled(model.isWaitingForGPS)
                    } else {
                        Button {
                            showEndConfirmation = true
                        } label: {
                            Label("END TRIP", systemImage: "stop.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 17)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                        .confirmationDialog("End this trip?", isPresented: $showEndConfirmation, titleVisibility: .visible) {
                            Button("Save and End Trip", role: .destructive) { model.endTrip() }
                            Button("Continue Trip", role: .cancel) { }
                        }
                    }

                    Text("OBD2 connection and battery data will be added in the next development phase.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
            }
            .background(Color.black.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

private struct SpeedGauge: View {
    let title: String
    let value: Double
    let unit: String

    var body: some View {
        VStack(spacing: 8) {
            Text(title.uppercased())
                .font(.caption.weight(.bold))
                .tracking(1.5)
                .foregroundStyle(.cyan)
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.12), lineWidth: 9)
                Circle()
                    .trim(from: 0, to: min(value / (unit == "mph" ? 120 : 200), 1))
                    .stroke(Color.cyan, style: StrokeStyle(lineWidth: 9, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                VStack(spacing: 0) {
                    Text("\(Int(value))")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .minimumScaleFactor(0.65)
                        .lineLimit(1)
                    Text(unit)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
        }
        .padding(12)
        .background(Color.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 18))
    }
}

private struct MetricTile: View {
    let title: String
    let value: String
    let unit: String
    let icon: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon).foregroundStyle(.cyan)
            Text(title).font(.system(size: 9, weight: .bold)).foregroundStyle(.secondary)
            Text(value).font(.system(size: 20, weight: .bold, design: .rounded)).lineLimit(1).minimumScaleFactor(0.7)
            Text(unit).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 14))
    }
}
