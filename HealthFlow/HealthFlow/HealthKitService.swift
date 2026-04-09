import Foundation
import HealthKit
import Combine

class HealthKitService: ObservableObject {
    let healthStore = HKHealthStore()

    @Published var stepCount: Double = 0
    @Published var heartRate: Double = 0
    @Published var sleepHours: Double = 0
    @Published var weeklySteps: [WeeklyDataPoint] = []
    @Published var weeklyHeartRate: [WeeklyDataPoint] = []
    @Published var weeklySleep: [WeeklyDataPoint] = []
    @Published var isAuthorized: Bool = false

    private let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
    private let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
    private let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!

    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let readTypes: Set<HKObjectType> = [stepType, heartRateType, sleepType]

        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, _ in
            DispatchQueue.main.async {
                self.isAuthorized = success
                if success {
                    self.fetchAllData()
                } else {
                    self.loadMockData()
                }
            }
        }
    }

    func fetchAllData() {
        fetchTodaySteps()
        fetchLatestHeartRate()
        fetchLastNightSleep()
        fetchWeeklySteps()
        fetchWeeklyHeartRate()
        fetchWeeklySleep()
    }

    // MARK: - Step Count
    func fetchTodaySteps() {
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            DispatchQueue.main.async {
                self.stepCount = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
            }
        }
        healthStore.execute(query)
    }

    // MARK: - Heart Rate
    func fetchLatestHeartRate() {
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, samples, _ in
            DispatchQueue.main.async {
                if let sample = samples?.first as? HKQuantitySample {
                    self.heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                }
            }
        }
        healthStore.execute(query)
    }

    // MARK: - Sleep
    func fetchLastNightSleep() {
        let now = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        let predicate = HKQuery.predicateForSamples(withStart: yesterday, end: now, options: .strictStartDate)

        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
            DispatchQueue.main.async {
                let totalSeconds = samples?.reduce(0.0) { result, sample in
                    result + sample.endDate.timeIntervalSince(sample.startDate)
                } ?? 0
                self.sleepHours = totalSeconds / 3600
            }
        }
        healthStore.execute(query)
    }

    // MARK: - Weekly Steps
    func fetchWeeklySteps() {
        let calendar = Calendar.current
        let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        var results: [WeeklyDataPoint] = []

        let group = DispatchGroup()

        for i in 0..<7 {
            group.enter()
            let date = calendar.date(byAdding: .day, value: -(6 - i), to: Date())!
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)

            let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
                let steps = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
                results.append(WeeklyDataPoint(day: days[i], value: steps))
                group.leave()
            }
            healthStore.execute(query)
        }

        group.notify(queue: .main) {
            self.weeklySteps = results.sorted { a, b in
                days.firstIndex(of: a.day)! < days.firstIndex(of: b.day)!
            }
        }
    }

    // MARK: - Weekly Heart Rate
    func fetchWeeklyHeartRate() {
        let calendar = Calendar.current
        let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        var results: [WeeklyDataPoint] = []
        let group = DispatchGroup()

        for i in 0..<7 {
            group.enter()
            let date = calendar.date(byAdding: .day, value: -(6 - i), to: Date())!
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)

            let query = HKStatisticsQuery(quantityType: heartRateType, quantitySamplePredicate: predicate, options: .discreteAverage) { _, result, _ in
                let bpm = result?.averageQuantity()?.doubleValue(for: HKUnit(from: "count/min")) ?? 0
                results.append(WeeklyDataPoint(day: days[i], value: bpm))
                group.leave()
            }
            healthStore.execute(query)
        }

        group.notify(queue: .main) {
            self.weeklyHeartRate = results.sorted { a, b in
                days.firstIndex(of: a.day)! < days.firstIndex(of: b.day)!
            }
        }
    }

    // MARK: - Weekly Sleep
    func fetchWeeklySleep() {
        let calendar = Calendar.current
        let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        var results: [WeeklyDataPoint] = []
        let group = DispatchGroup()

        for i in 0..<7 {
            group.enter()
            let date = calendar.date(byAdding: .day, value: -(6 - i), to: Date())!
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)

            let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
                let totalHours = (samples ?? []).reduce(0.0) {
                    $0 + $1.endDate.timeIntervalSince($1.startDate) / 3600
                }
                results.append(WeeklyDataPoint(day: days[i], value: totalHours))
                group.leave()
            }
            healthStore.execute(query)
        }

        group.notify(queue: .main) {
            self.weeklySleep = results.sorted { a, b in
                days.firstIndex(of: a.day)! < days.firstIndex(of: b.day)!
            }
        }
    }

    // MARK: - Mock Data (Simulator / No HealthKit)
    func loadMockData() {
        stepCount = 7842
        heartRate = 72
        sleepHours = 7.5

        let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        weeklySteps = zip(days, [6200, 8400, 5100, 9200, 7800, 11200, 7842]).map {
            WeeklyDataPoint(day: $0, value: $1)
        }
        weeklyHeartRate = zip(days, [68, 74, 71, 76, 69, 72, 72]).map {
            WeeklyDataPoint(day: $0, value: $1)
        }
        weeklySleep = zip(days, [6.5, 7.2, 8.0, 6.8, 7.5, 8.5, 7.5]).map {
            WeeklyDataPoint(day: $0, value: $1)
        }
    }
}
