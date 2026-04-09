[README.md](https://github.com/user-attachments/files/26595484/README.md)
# HealthFlow 🏃‍♂️

A modern Health & Wellness tracking iOS app built with SwiftUI, following MVVM architecture and integrating with Apple HealthKit.


## Screenshots

<p align="center">
  <img src="https://github.com/user-attachments/assets/d2446fcc-c950-4b3e-ae52-d8111cf59963" width="200"/>
  <img src="https://github.com/user-attachments/assets/c02ed49d-8b33-4f01-9524-aa1211145eac" width="200"/>
  <img src="https://github.com/user-attachments/assets/9a0c342f-b86b-4957-8e57-15b8ec67f80e" width="200"/>
  <img src="https://github.com/user-attachments/assets/1cc8b0da-6c2b-445d-818a-f18186213b59" width="200"/>
</p>

## Features

- **📊 Dashboard** — Unified overview of all health metrics with progress indicators
- **🚶 Activity Tracker** — Step count with circular progress ring and weekly bar chart
- **❤️ Heart Rate Monitor** — Live BPM display with weekly trend line chart
- **😴 Sleep Tracker** — Sleep duration tracking with quality assessment
- **💧 Water Intake** — Quick-add water logging with daily goal progress
- **😊 Mood Logger** — Daily mood tracking with notes and weekly average

## Tech Stack

| Layer | Technology |
|-------|-----------|
| UI Framework | SwiftUI |
| Architecture | MVVM |
| Health Data | HealthKit |
| Charts | Swift Charts (iOS 16+) |
| Persistence | UserDefaults (Mood & Water) |
| Minimum iOS | iOS 17.0 |

## Architecture

```
HealthFlow/
├── App/
│   ├── HealthFlowApp.swift       # App entry point
│   └── ContentView.swift         # Tab navigation
├── Models/
│   └── HealthModels.swift        # Data models (MoodEntry, WaterEntry, etc.)
├── ViewModels/
│   └── ViewModels.swift          # DashboardVM, WaterVM, MoodVM
├── Views/
│   ├── Components/
│   │   └── SharedComponents.swift # Reusable UI (MetricCard, Charts, etc.)
│   ├── Dashboard/
│   │   └── DashboardView.swift
│   ├── Activity/
│   │   └── ActivityHeartRateSleepViews.swift
│   └── Water/
│       └── WaterMoodViews.swift
├── Services/
│   └── HealthKitService.swift    # HealthKit queries & authorization
└── Supporting/
    └── Info.plist
```

## MVVM Pattern

```
View ──observes──> ViewModel ──uses──> Service/Model
 │                     │
 │                     └── @Published properties
 └── @StateObject / @EnvironmentObject
```

- **Models** — Pure data structures (`MoodEntry`, `WaterEntry`, `WeeklyDataPoint`)
- **ViewModels** — Business logic, state management, UserDefaults persistence
- **Views** — Pure SwiftUI rendering, no business logic
- **Services** — `HealthKitService` handles all HealthKit authorization and queries

## Setup

1. Clone the repo
```bash
git clone https://github.com/yourusername/HealthFlow.git
```

2. Open `HealthFlow.xcodeproj` in Xcode

3. Select your target device or simulator

4. Add your development team in **Signing & Capabilities**

5. Enable **HealthKit** capability in **Signing & Capabilities**

6. Run ▶️

> **Note:** HealthKit is not available on the iOS Simulator. The app automatically loads mock data when running on a simulator so you can see all features.

## HealthKit Permissions

The app requests read access to:
- Step Count
- Heart Rate  
- Sleep Analysis

Permissions are requested on first launch and handled gracefully — the app falls back to mock data if HealthKit is unavailable.

## Key Implementation Highlights

### HealthKit Async Queries
```swift
func fetchTodaySteps() {
    let predicate = HKQuery.predicateForSamples(
        withStart: Calendar.current.startOfDay(for: Date()),
        end: Date(),
        options: .strictStartDate
    )
    let query = HKStatisticsQuery(
        quantityType: stepType,
        quantitySamplePredicate: predicate,
        options: .cumulativeSum
    ) { _, result, _ in
        DispatchQueue.main.async {
            self.stepCount = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
        }
    }
    healthStore.execute(query)
}
```

### Reusable Chart Components
```swift
HealthBarChart(data: healthKit.weeklySteps, color: .blue, unit: "steps")
HealthLineChart(data: healthKit.weeklyHeartRate, color: .red)
```

### Persistent Mood & Water Logging
```swift
func addWater(_ amount: Double) {
    let entry = WaterEntry(amount: amount)
    entries.append(entry)
    saveEntries() // Codable + UserDefaults
}
```

## Future Improvements (v2)

- [ ] CoreData for robust local persistence
- [ ] Widgets for Home Screen metrics
- [ ] Apple Watch companion app
- [ ] Workout tracking integration
- [ ] CloudKit sync across devices
- [ ] Nutrition tracking
- [ ] Notification reminders (water, mood check-ins)

## Requirements

- iOS 17.0+
- Xcode 15+
- Swift 5.9+
- Physical device for HealthKit (Simulator uses mock data)

## License

MIT License — feel free to use this as a reference or starting point.

---

Built by [Rahul Nimje](https://github.com/yourusername) — Senior iOS Developer  
📍 Bangalore, India → Berlin, Germany 🇩🇪
