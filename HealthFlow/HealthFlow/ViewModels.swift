import Foundation
import SwiftUI
import Combine

// MARK: - Dashboard ViewModel
class DashboardViewModel: ObservableObject {
    @Published var greeting: String = ""
    @Published var date: String = ""

    init() {
        setupGreeting()
        setupDate()
    }

    private func setupGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: greeting = "Good Morning"
        case 12..<17: greeting = "Good Afternoon"
        default: greeting = "Good Evening"
        }
    }

    private func setupDate() {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        date = formatter.string(from: Date())
    }
}

// MARK: - Water ViewModel
class WaterViewModel: ObservableObject {
    @Published var entries: [WaterEntry] = []
    @Published var dailyGoal: Double = 2500 // ml
    @Published var showAddSheet: Bool = false
    @Published var customAmount: String = ""

    private let storageKey = "water_entries"

    var todayTotal: Double {
        let today = Calendar.current.startOfDay(for: Date())
        return entries
            .filter { Calendar.current.startOfDay(for: $0.date) == today }
            .reduce(0) { $0 + $1.amount }
    }

    var progress: Double {
        min(todayTotal / dailyGoal, 1.0)
    }

    var todayEntries: [WaterEntry] {
        let today = Calendar.current.startOfDay(for: Date())
        return entries
            .filter { Calendar.current.startOfDay(for: $0.date) == today }
            .sorted { $0.date > $1.date }
    }

    init() {
        loadEntries()
    }

    func addWater(_ amount: Double) {
        let entry = WaterEntry(amount: amount)
        entries.append(entry)
        saveEntries()
    }

    func removeEntry(_ entry: WaterEntry) {
        entries.removeAll { $0.id == entry.id }
        saveEntries()
    }

    private func saveEntries() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    private func loadEntries() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([WaterEntry].self, from: data) {
            entries = decoded
        }
    }
}

// MARK: - Mood ViewModel
class MoodViewModel: ObservableObject {
    @Published var entries: [MoodEntry] = []
    @Published var selectedMood: MoodType? = nil
    @Published var noteText: String = ""
    @Published var showAddSheet: Bool = false

    private let storageKey = "mood_entries"

    var todayMood: MoodEntry? {
        let today = Calendar.current.startOfDay(for: Date())
        return entries
            .filter { Calendar.current.startOfDay(for: $0.date) == today }
            .last
    }

    var recentEntries: [MoodEntry] {
        Array(entries.sorted { $0.date > $1.date }.prefix(7))
    }

    var weeklyAverage: Double {
        let recent = recentEntries
        guard !recent.isEmpty else { return 0 }
        let total = recent.reduce(0) { $0 + $1.mood.score }
        return Double(total) / Double(recent.count)
    }

    init() {
        loadEntries()
    }

    func logMood() {
        guard let mood = selectedMood else { return }
        let entry = MoodEntry(mood: mood, note: noteText)
        entries.append(entry)
        saveEntries()
        selectedMood = nil
        noteText = ""
        showAddSheet = false
    }

    private func saveEntries() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    private func loadEntries() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([MoodEntry].self, from: data) {
            entries = decoded
        }
    }
}
