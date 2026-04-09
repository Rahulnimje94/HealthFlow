//
//  ContentView.swift
//  HealthFlow
//
//  Created by Rahul_Nimje on 09/04/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var healthKit: HealthKitService
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
                .tag(0)

            ActivityView()
                .tabItem {
                    Label("Activity", systemImage: "figure.walk")
                }
                .tag(1)

            WaterView()
                .tabItem {
                    Label("Water", systemImage: "drop.fill")
                }
                .tag(2)

            MoodView()
                .tabItem {
                    Label("Mood", systemImage: "face.smiling.fill")
                }
                .tag(3)

            SleepView()
                .tabItem {
                    Label("Sleep", systemImage: "moon.fill")
                }
                .tag(4)
        }
        .tint(.blue)
        .onAppear {
            // Load mock data for simulator
            if !healthKit.isAuthorized {
                healthKit.loadMockData()
            }
        }
    }
}


#Preview {
    ContentView()
        .environmentObject(HealthKitService())
}
