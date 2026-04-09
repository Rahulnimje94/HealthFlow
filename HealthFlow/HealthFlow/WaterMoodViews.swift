import SwiftUI

// MARK: - Water View
struct WaterView: View {
    @StateObject private var viewModel = WaterViewModel()

    let quickAmounts: [(String, Double)] = [
        ("Small Cup", 150),
        ("Glass", 250),
        ("Bottle", 500),
        ("Large", 750)
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {

                // Progress Card
                CardContainer {
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .stroke(Color.cyan.opacity(0.15), lineWidth: 16)
                                .frame(width: 160, height: 160)
                            Circle()
                                .trim(from: 0, to: viewModel.progress)
                                .stroke(Color.cyan, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                                .frame(width: 160, height: 160)
                                .rotationEffect(.degrees(-90))
                                .animation(.easeInOut(duration: 0.8), value: viewModel.progress)

                            VStack(spacing: 4) {
                                Image(systemName: "drop.fill")
                                    .foregroundColor(.cyan)
                                Text("\(Int(viewModel.todayTotal))ml")
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                Text("of \(Int(viewModel.dailyGoal))ml")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                        }

                        HStack(spacing: 32) {
                            StatRow(label: "Goal", value: "\(Int(viewModel.dailyGoal))ml", color: .cyan)
                            StatRow(label: "Remaining", value: "\(max(0, Int(viewModel.dailyGoal - viewModel.todayTotal)))ml", color: .gray)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)

                // Quick Add
                CardContainer {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Add")
                            .font(.system(size: 16, weight: .semibold))

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(quickAmounts, id: \.0) { item in
                                Button {
                                    withAnimation {
                                        viewModel.addWater(item.1)
                                    }
                                } label: {
                                    VStack(spacing: 6) {
                                        Image(systemName: "drop.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(.cyan)
                                        Text(item.0)
                                            .font(.system(size: 13, weight: .medium))
                                        Text("\(Int(item.1))ml")
                                            .font(.system(size: 11))
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.cyan.opacity(0.08))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }

                        Button {
                            viewModel.showAddSheet = true
                        } label: {
                            Label("Add Custom Amount", systemImage: "plus")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.cyan)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Color.cyan.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
                .padding(.horizontal)

                // Today's Log
                if !viewModel.todayEntries.isEmpty {
                    CardContainer {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Today's Log")
                                .font(.system(size: 16, weight: .semibold))

                            ForEach(viewModel.todayEntries) { entry in
                                HStack {
                                    Image(systemName: "drop.fill")
                                        .foregroundColor(.cyan)
                                        .frame(width: 24)
                                    Text("\(Int(entry.amount))ml")
                                        .font(.system(size: 14, weight: .medium))
                                    Spacer()
                                    Text(entry.date, style: .time)
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }
                                .swipeActions {
                                    Button(role: .destructive) {
                                        viewModel.removeEntry(entry)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }

                                if entry.id != viewModel.todayEntries.last?.id {
                                    Divider()
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer(minLength: 20)
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Water Intake")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $viewModel.showAddSheet) {
            CustomWaterSheet(viewModel: viewModel)
                .presentationDetents([.height(220)])
        }
    }
}

// MARK: - Custom Water Sheet
struct CustomWaterSheet: View {
    @ObservedObject var viewModel: WaterViewModel
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 20) {
            Text("Custom Amount")
                .font(.system(size: 18, weight: .bold))
                .padding(.top)

            HStack {
                TextField("Amount in ml", text: $viewModel.customAmount)
                    .keyboardType(.numberPad)
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .focused($isFocused)
                Text("ml")
                    .font(.system(size: 18))
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)

            Button {
                if let amount = Double(viewModel.customAmount), amount > 0 {
                    viewModel.addWater(amount)
                    viewModel.customAmount = ""
                    viewModel.showAddSheet = false
                }
            } label: {
                Text("Add Water")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.cyan)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
        }
        .onAppear { isFocused = true }
    }
}

// MARK: - Mood View
struct MoodView: View {
    @StateObject private var viewModel = MoodViewModel()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {

                // Today's Mood
                CardContainer {
                    VStack(spacing: 16) {
                        if let today = viewModel.todayMood {
                            VStack(spacing: 8) {
                                Text(today.mood.emoji)
                                    .font(.system(size: 56))
                                Text("Feeling \(today.mood.rawValue)")
                                    .font(.system(size: 20, weight: .bold))
                                if !today.note.isEmpty {
                                    Text(today.note)
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                Text(today.date, style: .time)
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                        } else {
                            VStack(spacing: 12) {
                                Text("How are you feeling?")
                                    .font(.system(size: 17, weight: .semibold))

                                HStack(spacing: 12) {
                                    ForEach(MoodType.allCases, id: \.self) { mood in
                                        Button {
                                            viewModel.selectedMood = mood
                                            viewModel.showAddSheet = true
                                        } label: {
                                            VStack(spacing: 4) {
                                                Text(mood.emoji)
                                                    .font(.system(size: 28))
                                                Text(mood.rawValue)
                                                    .font(.system(size: 9, weight: .medium))
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)

                // Weekly Average
                if !viewModel.recentEntries.isEmpty {
                    CardContainer {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Weekly Mood Average")
                                    .font(.system(size: 16, weight: .semibold))
                                Spacer()
                                Text(String(format: "%.1f/5", viewModel.weeklyAverage))
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.orange)
                            }

                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.orange.opacity(0.15))
                                        .frame(height: 10)
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.orange)
                                        .frame(width: geo.size.width * (viewModel.weeklyAverage / 5), height: 10)
                                }
                            }
                            .frame(height: 10)
                        }
                    }
                    .padding(.horizontal)

                    // Recent Entries
                    CardContainer {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recent Moods")
                                .font(.system(size: 16, weight: .semibold))

                            ForEach(viewModel.recentEntries) { entry in
                                HStack(spacing: 12) {
                                    Text(entry.mood.emoji)
                                        .font(.system(size: 24))
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(entry.mood.rawValue)
                                            .font(.system(size: 14, weight: .medium))
                                        if !entry.note.isEmpty {
                                            Text(entry.note)
                                                .font(.system(size: 12))
                                                .foregroundColor(.secondary)
                                                .lineLimit(1)
                                        }
                                    }
                                    Spacer()
                                    Text(entry.date, style: .date)
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                }

                                if entry.id != viewModel.recentEntries.last?.id {
                                    Divider()
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer(minLength: 20)
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Mood")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $viewModel.showAddSheet) {
            MoodLogSheet(viewModel: viewModel)
                .presentationDetents([.height(300)])
        }
    }
}

// MARK: - Mood Log Sheet
struct MoodLogSheet: View {
    @ObservedObject var viewModel: MoodViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("Add a note (optional)")
                .font(.system(size: 18, weight: .bold))
                .padding(.top)

            if let mood = viewModel.selectedMood {
                HStack(spacing: 8) {
                    Text(mood.emoji)
                        .font(.system(size: 30))
                    Text("Feeling \(mood.rawValue)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(mood.color)
                }
            }

            TextField("What's on your mind?", text: $viewModel.noteText, axis: .vertical)
                .lineLimit(3)
                .padding()
                .background(Color(.systemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)

            Button {
                viewModel.logMood()
            } label: {
                Text("Save Mood")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.orange)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
        }
    }
}
