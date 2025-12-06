//
//  PrayerListView.swift
//  iPrayer
//
//  Created by Youssef Keram on 11/23/25.
//

import SwiftUI
import Combine

struct PrayerListView: View {
    @EnvironmentObject var viewModel: PrayerViewModel
    @State private var timeRemaining: String = "00:00:00"
    
    // Timer to update the countdown every second
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView {
            // FIX: Removed ZStack and LinearGradient.
            // The background is now handled by ContentView.
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {
                    
                    // 1. HERO SECTION (Countdown)
                    if let nextPrayer = viewModel.prayerTimes.first(where: { $0.isNext }) {
                        HeroSection(
                            prayerName: nextPrayer.name,
                            prayerTime: nextPrayer.time,
                            location: viewModel.locationName,
                            timeRemaining: timeRemaining
                        )
                    } else {
                        Text("Loading Prayers...")
                            .foregroundColor(.white)
                            .padding(.top, 50)
                    }
                    
                    // 2. GLASS CARD LIST
                    VStack(spacing: 15) {
                        ForEach(viewModel.prayerTimes) { prayer in
                            GlassPrayerRow(prayer: prayer)
                        }
                    }
                    .padding(.horizontal)
                    // Add extra padding at the bottom of the SCROLL CONTENT, not the view
                    // This ensures you can scroll the last item above the tab bar
                    .padding(.bottom, 100)
                }
                .padding(.top, 20)
            }
            .background(Color.clear) // Ensure transparency
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Fix for some iPad/Pro Max layouts
        .onReceive(timer) { _ in
            updateCountdown()
        }
        .onAppear {
            updateCountdown()
        }
    }
    
    func updateCountdown() {
        guard let nextPrayer = viewModel.prayerTimes.first(where: { $0.isNext }) else { return }
        
        let diff = nextPrayer.time.timeIntervalSinceNow
        
        if diff > 0 {
            let hours = Int(diff) / 3600
            let minutes = (Int(diff) % 3600) / 60
            let seconds = Int(diff) % 60
            timeRemaining = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            timeRemaining = "00:00:00"
            if diff < -60 { viewModel.refreshPrayers() }
        }
    }
}

// MARK: - Subviews

struct HeroSection: View {
    let prayerName: String
    let prayerTime: Date
    let location: String
    let timeRemaining: String
    
    var body: some View {
        VStack(spacing: 10) {
            // Location Pill
            HStack {
                Image(systemName: "location.fill")
                    .font(.caption)
                Text(location)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(.white.opacity(0.7))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.black.opacity(0.2))
            .cornerRadius(20)
            
            Spacer().frame(height: 10)
            
            // Big Icon
            Image(systemName: iconForPrayer(prayerName))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundColor(.yellow.opacity(0.9))
                .shadow(color: .yellow.opacity(0.5), radius: 20, x: 0, y: 0)
            
            // Prayer Name
            Text(prayerName)
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("starts in")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            // The Countdown
            Text(timeRemaining)
                .font(.system(size: 50, weight: .light, design: .monospaced))
                .foregroundColor(.teal)
                .shadow(color: .teal.opacity(0.3), radius: 10)
            
            // Actual Time
            Text("at " + prayerTime.formatted(date: .omitted, time: .shortened))
                .font(.headline)
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.vertical, 30)
    }
    
    func iconForPrayer(_ name: String) -> String {
        switch name {
        case "Fajr": return "sun.haze.fill"
        case "Sunrise": return "sunrise.fill"
        case "Dhuhr": return "sun.max.fill"
        case "Asr": return "sun.min.fill"
        case "Maghrib": return "sunset.fill"
        case "Isha": return "moon.stars.fill"
        default: return "clock.fill"
        }
    }
}

struct GlassPrayerRow: View {
    let prayer: PrayerItem
    
    var isPast: Bool {
        return !prayer.isNext && prayer.time < Date()
    }
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(prayer.isNext ? Color.teal : Color.clear)
                    .frame(width: 36, height: 36)
                    .opacity(0.2)
                
                Image(systemName: prayer.icon)
                    .foregroundColor(prayer.isNext ? .teal : (isPast ? .gray.opacity(0.5) : .white))
            }
            
            Text(prayer.name)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(isPast ? .gray.opacity(0.5) : .white)
            
            Spacer()
            
            Text(prayer.time, style: .time)
                .font(.system(size: 16, weight: prayer.isNext ? .bold : .regular, design: .monospaced))
                .foregroundColor(prayer.isNext ? .teal : (isPast ? .gray.opacity(0.5) : .white))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    prayer.isNext
                    ? AnyShapeStyle(Color.teal.opacity(0.1))
                    : AnyShapeStyle(Material.ultraThinMaterial)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(prayer.isNext ? Color.teal.opacity(0.6) : Color.white.opacity(0.05), lineWidth: 1)
        )
        .opacity(isPast ? 0.6 : 1.0)
        .scaleEffect(prayer.isNext ? 1.05 : 1.0)
        .animation(.spring(), value: prayer.isNext)
    }
}
