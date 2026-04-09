//
//  HealthFlowApp.swift
//  HealthFlow
//
//  Created by Rahul_Nimje on 09/04/26.
//

import SwiftUI

@main
struct HealthFlowApp: App {
    @StateObject private var healthKitService = HealthKitService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(healthKitService)
                .onAppear {
                    healthKitService.requestAuthorization()
                }
        }
    }
}
