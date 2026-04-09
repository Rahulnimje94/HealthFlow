import Foundation
import SwiftUI

// MARK: - Mood Entry
enum MoodType: String, CaseIterable, Codable {
    case great = "Great"
    case good = "Good"
    case okay = "Okay"
    case bad = "Bad"
    case terrible = "Terrible"

    var emoji: String {
        switch self {
        case .great: return "😄"
        case .good: return "🙂"
        case .okay: return "😐"
        case .bad: return "😔"
        case .terrible: return "😢"
        }
    }

    var color: Color {
        switch self {
        case .great: return Color(hex: "4CAF50")
        case .good: return Color(hex: "8BC34A")
        case .okay: return Color(hex: "FFC107")
        case .bad: return Color(hex: "FF7043")
        case .terrible: return Color(hex: "F44336")
        }
    }

    var score: Int {
        switch self {
        case .great: return 5
        case .good: return 4
        case .okay: return 3
        case .bad: return 2
        case .terrible: return 1
        }
    }
}

struct MoodEntry: Identifiable, Codable {
    let id: UUID
    let mood: MoodType
    let note: String
    let date: Date

    init(id: UUID = UUID(), mood: MoodType, note: String = "", date: Date = Date()) {
        self.id = id
        self.mood = mood
        self.note = note
        self.date = date
    }
}

// MARK: - Water Entry
struct WaterEntry: Identifiable, Codable {
    let id: UUID
    let amount: Double // in ml
    let date: Date

    init(id: UUID = UUID(), amount: Double, date: Date = Date()) {
        self.id = id
        self.amount = amount
        self.date = date
    }
}

// MARK: - Health Metric
struct HealthMetric: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    let progress: Double // 0.0 to 1.0
}

// MARK: - Weekly Data Point
struct WeeklyDataPoint: Identifiable {
    let id = UUID()
    let day: String
    let value: Double
}

// MARK: - Sleep Data
struct SleepData: Identifiable {
    let id = UUID()
    let startDate: Date
    let endDate: Date
    var duration: Double {
        endDate.timeIntervalSince(startDate) / 3600
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
