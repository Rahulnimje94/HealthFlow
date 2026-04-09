import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var healthKit: HealthKitService
    @StateObject private var viewModel = DashboardViewModel()

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {

                    // MARK: - Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.greeting)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                            Text("Rahul 👋")
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            Text(viewModel.date)
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "bell.badge")
                            .font(.system(size: 20))
                            .foregroundColor(.primary)
                            .padding(10)
                            .background(Color(.systemBackground))
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.08), radius: 6)
                    }
                    .padding(.horizontal)

                    // MARK: - Metrics Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {

                        NavigationLink(destination: ActivityView()) {
                            MetricCard(
                                title: "Steps Today",
                                value: healthKit.stepCount >= 1000
                                    ? String(format: "%.1fk", healthKit.stepCount / 1000)
                                    : "\(Int(healthKit.stepCount))",
                                unit: "steps",
                                icon: "figure.walk",
                                color: .blue,
                                progress: min(healthKit.stepCount / 10000, 1.0)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())

                        NavigationLink(destination: HeartRateView()) {
                            MetricCard(
                                title: "Heart Rate",
                                value: "\(Int(healthKit.heartRate))",
                                unit: "bpm",
                                icon: "heart.fill",
                                color: .red,
                                progress: min(healthKit.heartRate / 200, 1.0)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())

                        NavigationLink(destination: SleepView()) {
                            MetricCard(
                                title: "Sleep",
                                value: String(format: "%.1f", healthKit.sleepHours),
                                unit: "hrs",
                                icon: "moon.fill",
                                color: .indigo,
                                progress: min(healthKit.sleepHours / 8, 1.0)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())

                        NavigationLink(destination: WaterView()) {
                            WaterMetricCard()
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal)

                    // MARK: - Mood Section
                    VStack(spacing: 12) {
                        SectionHeader(title: "Today's Mood")
                            .padding(.horizontal)

                        NavigationLink(destination: MoodView()) {
                            MoodSummaryCard()
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal)
                    }

                    // MARK: - Weekly Activity
                    VStack(spacing: 12) {
                        SectionHeader(title: "Weekly Steps")
                            .padding(.horizontal)

                        CardContainer {
                            VStack(alignment: .leading, spacing: 12) {
                                if healthKit.weeklySteps.isEmpty {
                                    ProgressView()
                                        .frame(maxWidth: .infinity, minHeight: 160)
                                } else {
                                    HealthBarChart(
                                        data: healthKit.weeklySteps,
                                        color: .blue,
                                        unit: "steps"
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    Spacer(minLength: 20)
                }
                .padding(.top, 8)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
            .refreshable {
                healthKit.fetchAllData()
            }
        }
    }
}

// MARK: - Water Metric Card (uses WaterViewModel)
struct WaterMetricCard: View {
    @StateObject private var waterVM = WaterViewModel()

    var body: some View {
        MetricCard(
            title: "Water Intake",
            value: String(format: "%.0f", waterVM.todayTotal),
            unit: "ml",
            icon: "drop.fill",
            color: .cyan,
            progress: waterVM.progress
        )
    }
}

// MARK: - Mood Summary Card
struct MoodSummaryCard: View {
    @StateObject private var moodVM = MoodViewModel()

    var body: some View {
        CardContainer {
            HStack(spacing: 16) {
                if let todayMood = moodVM.todayMood {
                    Text(todayMood.mood.emoji)
                        .font(.system(size: 44))
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Feeling \(todayMood.mood.rawValue)")
                            .font(.system(size: 16, weight: .semibold))
                        if !todayMood.note.isEmpty {
                            Text(todayMood.note)
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.system(size: 14))
                } else {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.orange)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Log Your Mood")
                            .font(.system(size: 16, weight: .semibold))
                        Text("How are you feeling today?")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.system(size: 14))
                }
            }
        }
    }
}

#Preview {
    DashboardView().environmentObject(HealthKitService())
}
