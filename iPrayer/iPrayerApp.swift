//
//  iPrayerApp.swift
//  iPrayer
//
//  Created by Youssef Keram on 11/23/25.
//

import SwiftUI
import UserNotifications

@main
struct iPrayerApp: App {
    @Environment(\.scenePhase) var scenePhase
    @StateObject private var viewModel = PrayerViewModel()
    
    // MARK: - Splash Screen State
    @State private var isSplashScreenActive: Bool = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // 1. The Main App (Always loaded in background so it's ready)
                ContentView()
                    .environmentObject(viewModel)
                    .preferredColorScheme(.dark)
                
                // 2. The Splash Screen (Overlay)
                if isSplashScreenActive {
                    SplashScreenView()
                        .transition(.opacity) // Fade transition
                        .zIndex(1) // Ensure it sits on top
                }
            }
            .onAppear {
                // Request Notifications
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    print("Notification permission granted: \(granted)")
                }
                
                // MARK: - Splash Logic
                // Wait 3 seconds, then fade out
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    withAnimation(.easeOut(duration: 1.0)) {
                        isSplashScreenActive = false
                    }
                }
            }
            // Background refresh logic
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    viewModel.refreshPrayers()
                }
            }
        }
    }
}
