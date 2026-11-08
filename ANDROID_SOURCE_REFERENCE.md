# Android source reference inspected for iOS port

Original archive: SupremeIoniq6Logger.zip

Key source files:
- `ObdBle.kt`: BLE transport discovery, Nordic UART UUID profile, Hyundai/Kia EV diagnostic response parsing, SOC/current/power/energy state.
- `TripLog.kt`: trip/stage model, JSON persistence, stop/cost/statistics logic, CSV/PDF summary generation.
- `LocationTracker.kt`: GPS tracking, distance filtering, moving speed statistics.
- `ChargeAutomation.kt`: charging-state detection and nearby charger lookup.
- `OpenChargeMap.kt`: nearby charging station lookup.

The iOS implementation should port these behaviors deliberately rather than translating Kotlin line-by-line. Verify OBD byte offsets, command timing, charge-vs-regeneration logic, and adapter compatibility on real hardware.
