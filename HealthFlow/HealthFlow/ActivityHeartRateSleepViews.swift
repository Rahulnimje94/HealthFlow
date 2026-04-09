import SwiftUI
import Charts

// MARK: - Activity View
struct ActivityView: View {
    @EnvironmentObject var healthKit: HealthKitService
    private let goal: Double = 10000

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {

                // Progress Ring
                CardContainer {
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .stroke(Color.blue.opacity(0.15), lineWidth: 16)
                                .frame(width: 160, height: 160)
                            Circle()
                                .trim(from: 0, to: min(healthKit.stepCount / goal, 1.0))
                                .stroke(Color.blue, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                                .frame(width: 160, height: 160)
                                .rotationEffect(.degrees(-90))
                                .animation(.easeInOut(duration: 1.0), value: healthKit.stepCount)

                            VStack(spacing: 4) {
                                Text("\(Int(healthKit.stepCount))")
                                    .font(.system(size: 30, weight: .bold, design: .rounded))
                                Text("of \(Int(goal)) steps")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                        }

                        HStack(spacing: 32) {
                            StatRow(label: "Goal", value: "\(Int(goal))", color: .blue)
                            StatRow(label: "Remaining", value: "\(max(0, Int(goal - healthKit.stepCount)))", color: .gray)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)

                // Weekly Chart
                CardContainer {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Weekly Steps")
                            .font(.system(size: 16, weight: .semibold))
                        if healthKit.weeklySteps.isEmpty {
                            ProgressView().frame(maxWidth: .infinity, minHeight: 160)
                        } else {
                            HealthBarChart(data: healthKit.weeklySteps, color: .blue, unit: "steps")
                        }
                    }
                }
                .padding(.horizontal)

                // Tips Card
                CardContainer {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Activity Tips", systemImage: "lightbulb.fill")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.orange)
                        Text("Taking 10,000 steps daily reduces risk of heart disease by up to 30%. Try a 20-minute walk after lunch!")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Activity")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Heart Rate View
struct HeartRateView: View {
    @EnvironmentObject var healthKit: HealthKitService

    var heartRateStatus: (String, Color) {
        let hr = healthKit.heartRate
        switch hr {
        case 0..<60: return ("Low", .blue)
        case 60..<100: return ("Normal", .green)
        case 100..<120: return ("Elevated", .orange)
        default: return ("High", .red)
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {

                // Current BPM Card
                CardContainer {
                    VStack(spacing: 12) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.red)
                            .symbolEffect(.pulse)

                        HStack(alignment: .lastTextBaseline, spacing: 6) {
                            Text("\(Int(healthKit.heartRate))")
                                .font(.system(size: 56, weight: .bold, design: .rounded))
                            Text("BPM")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.secondary)
                                .padding(.bottom, 8)
                        }

                        Text(heartRateStatus.0)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(heartRateStatus.1)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 6)
                            .background(heartRateStatus.1.opacity(0.12))
                            .clipShape(Capsule())
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)

                // Weekly Chart
                CardContainer {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Weekly Average BPM")
                            .font(.system(size: 16, weight: .semibold))
                        if healthKit.weeklyHeartRate.isEmpty {
                            ProgressView().frame(maxWidth: .infinity, minHeight: 160)
                        } else {
                            HealthLineChart(data: healthKit.weeklyHeartRate, color: .red)
                        }
                    }
                }
                .padding(.horizontal)

                // Zones Card
                CardContainer {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Heart Rate Zones")
                            .font(.system(size: 16, weight: .semibold))
                        StatRow(label: "Resting (< 60 bpm)", value: "Low", color: .blue)
                        Divider()
                        StatRow(label: "Normal (60-100 bpm)", value: "Healthy", color: .green)
                        Divider()
                        StatRow(label: "Elevated (100-120 bpm)", value: "Active", color: .orange)
                        Divider()
                        StatRow(label: "High (> 120 bpm)", value: "Intense", color: .red)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Heart Rate")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Sleep View
struct SleepView: View {
    @EnvironmentObject var healthKit: HealthKitService

    var sleepQuality: (String, Color) {
        switch healthKit.sleepHours {
        case 0..<5: return ("Poor", .red)
        case 5..<6: return ("Fair", .orange)
        case 6..<7: return ("Good", .yellow)
        case 7...: return ("Excellent", .green)
        default: return ("No Data", .gray)
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {

                // Sleep Summary Card
                CardContainer {
                    VStack(spacing: 12) {
                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.indigo)

                        HStack(alignment: .lastTextBaseline, spacing: 6) {
                            Text(String(format: "%.1f", healthKit.sleepHours))
                                .font(.system(size: 56, weight: .bold, design: .rounded))
                            Text("hrs")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.secondary)
                                .padding(.bottom, 8)
                        }

                        Text(sleepQuality.0)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(sleepQuality.1)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 6)
                            .background(sleepQuality.1.opacity(0.12))
                            .clipShape(Capsule())

                        // Progress bar
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Goal: 8 hours")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\(Int(min(healthKit.sleepHours / 8 * 100, 100)))%")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.indigo)
                            }
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.indigo.opacity(0.15))
                                        .frame(height: 8)
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.indigo)
                                        .frame(width: geo.size.width * min(healthKit.sleepHours / 8, 1.0), height: 8)
                                        .animation(.easeInOut(duration: 0.8), value: healthKit.sleepHours)
                                }
                            }
                            .frame(height: 8)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)

                // Weekly Chart
                CardContainer {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Weekly Sleep (hrs)")
                            .font(.system(size: 16, weight: .semibold))
                        if healthKit.weeklySleep.isEmpty {
                            ProgressView().frame(maxWidth: .infinity, minHeight: 160)
                        } else {
                            HealthBarChart(data: healthKit.weeklySleep, color: .indigo, unit: "hrs")
                        }
                    }
                }
                .padding(.horizontal)

                // Tips
                CardContainer {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Sleep Tips", systemImage: "lightbulb.fill")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.orange)
                        Text("Adults need 7-9 hours of sleep nightly. Maintain a consistent sleep schedule, avoid screens 1 hour before bed.")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Sleep")
        .navigationBarTitleDisplayMode(.large)
    }
}
