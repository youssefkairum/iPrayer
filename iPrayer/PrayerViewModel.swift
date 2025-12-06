//
//  PrayerViewModel.swift
//  iPrayer
//
//  Created by Youssef Keram on 11/24/25.
//

import Foundation
import Combine
import CoreLocation
import MapKit
import Adhan
import SwiftUI

// MARK: - Model
struct PrayerItem: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let time: Date
    let isNext: Bool
    
    var icon: String {
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

// MARK: - ViewModel
@MainActor // Force all updates to happen on Main Thread (Modern Concurrency)
class PrayerViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published var prayerTimes: [PrayerItem] = []
    @Published var locationName: String = "Locating..."
    @Published var qiblaDirection: Double = 0.0
    @Published var currentHeading: Double = 0.0
    @Published var nextPrayerTime: String = "--:--"
    @Published var nextPrayerName: String = ""
    @Published var locationError: String?
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - Compass Battery Management
    func startCompass() {
        locationManager.startUpdatingHeading()
    }
    
    func stopCompass() {
        locationManager.stopUpdatingHeading()
    }
    
    // MARK: - Location Delegate
    
    // Non-isolated is required because CLLocationManagerDelegate methods are not automatically MainActor
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Stop updating location once we have a fix to save battery
        manager.stopUpdatingLocation()
        
        // Switch back to Main Actor to update UI and trigger calculations
        Task {
            await updateLocationData(location: location)
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let heading = newHeading.trueHeading > 0 ? newHeading.trueHeading : newHeading.magneticHeading
        
        // Update UI on Main Thread
        Task { @MainActor in
            self.currentHeading = heading
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.locationError = "Please enable location services."
        }
    }
    
    // MARK: - Async Logic
    
    private func updateLocationData(location: CLLocation) async {
        // 1. Fetch City Name (iOS 26+ Modern MapKit Approach)
        if locationName == "Locating..." {
            await fetchCityName(from: location)
        }
        
        // 2. Calculate Prayers
        calculatePrayers(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }
    
    private func fetchCityName(from location: CLLocation) async {
        do {
            // iOS 26+ Modern API: Using MKReverseGeocodingRequest
            guard let request = MKReverseGeocodingRequest(location: location) else {
                self.locationName = "Unknown Location"
                return
            }
            
            let mapItems = try await request.mapItems
            
            if let mapItem = mapItems.first {
                // Try addressRepresentations (iOS 26+ preferred API)
                if let addressReps = mapItem.addressRepresentations {
                    // Access the structured address components
                    if let cityName = addressReps.cityName {
                        self.locationName = cityName
                    } else if let regionName = addressReps.regionName {
                        self.locationName = regionName
                    } else {
                        self.locationName = "Unknown Location"
                    }
                }
                // Fallback to name if available
                else if let name = mapItem.name {
                    self.locationName = name
                } else {
                    self.locationName = "Unknown Location"
                }
            } else {
                self.locationName = "Unknown Location"
            }
        } catch {
            print("Geocoding failed: \(error.localizedDescription)")
            self.locationName = "Unknown Location"
        }
    }
    
    // MARK: - Public Refresh Method
        func refreshPrayers() {
            // Trigger a recalculation using the last known location
            if let location = locationManager.location {
                calculatePrayers(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            }
        }

        // MARK: - Calculation Logic
        
        private func calculatePrayers(latitude: Double, longitude: Double) {
            let coordinates = Coordinates(latitude: latitude, longitude: longitude)
            let cal = Calendar(identifier: .gregorian)
            let dateComponents = cal.dateComponents([.year, .month, .day], from: Date())
            
            // 1. LOAD SAVED SETTINGS (Replaces Hardcoded Values)
            let methodString = UserDefaults.standard.string(forKey: "calculationMethod") ?? "muslimWorldLeague"
            let madhabString = UserDefaults.standard.string(forKey: "madhab") ?? "shafi"
            
            // Map String -> Adhan.CalculationMethod
            var method: CalculationMethod = .muslimWorldLeague
            switch methodString {
            case "muslimWorldLeague": method = .muslimWorldLeague
            case "egyptian": method = .egyptian
            case "karachi": method = .karachi
            case "ummAlQura": method = .ummAlQura
            case "dubai": method = .dubai
            case "northAmerica": method = .northAmerica
            case "kuwait": method = .kuwait
            case "qatar": method = .qatar
            case "singapore": method = .singapore
            case "turkey": method = .turkey
            case "tehran": method = .tehran
            default: method = .muslimWorldLeague
            }
            
            var params = method.params
            
            // Map String -> Adhan.Madhab
            if madhabString == "hanafi" {
                params.madhab = .hanafi
            } else {
                params.madhab = .shafi // Standard (includes Maliki & Hanbali)
            }
            
            // 2. Calculate Today's Prayers
            guard let todayPrayers = PrayerTimes(coordinates: coordinates, date: dateComponents, calculationParameters: params) else { return }
            
            // 3. Determine Next Prayer and List Data
            let next = todayPrayers.nextPrayer()
            
            var displayPrayers = todayPrayers
            var nextPrayerDate = Date()
            var nextPrayerNameStr = ""
            var isNextDay = false
            
            if let nextP = next {
                // Case A: Still have prayers today
                displayPrayers = todayPrayers
                nextPrayerDate = todayPrayers.time(for: nextP)
                nextPrayerNameStr = self.prayerNameString(nextP)
                isNextDay = false
            } else {
                // Case B: Finished for today (After Isha) -> Switch to Tomorrow
                let tomorrow = cal.date(byAdding: .day, value: 1, to: Date())!
                let tomorrowComponents = cal.dateComponents([.year, .month, .day], from: tomorrow)
                
                if let tomorrowPrayers = PrayerTimes(coordinates: coordinates, date: tomorrowComponents, calculationParameters: params) {
                    displayPrayers = tomorrowPrayers
                    nextPrayerDate = tomorrowPrayers.fajr
                    nextPrayerNameStr = "Fajr"
                    isNextDay = true
                } else {
                    nextPrayerDate = Date()
                    nextPrayerNameStr = "Unknown"
                    isNextDay = false
                }
            }
            
            // 4. Build List
            let newItems = [
                PrayerItem(name: "Fajr", time: displayPrayers.fajr, isNext: (!isNextDay && next == .fajr) || (isNextDay && nextPrayerNameStr == "Fajr")),
                PrayerItem(name: "Sunrise", time: displayPrayers.sunrise, isNext: !isNextDay && next == .sunrise),
                PrayerItem(name: "Dhuhr", time: displayPrayers.dhuhr, isNext: !isNextDay && next == .dhuhr),
                PrayerItem(name: "Asr", time: displayPrayers.asr, isNext: !isNextDay && next == .asr),
                PrayerItem(name: "Maghrib", time: displayPrayers.maghrib, isNext: !isNextDay && next == .maghrib),
                PrayerItem(name: "Isha", time: displayPrayers.isha, isNext: !isNextDay && next == .isha)
            ]
            
            // 5. Update UI
            let qibla = Qibla(coordinates: coordinates)
            
            DispatchQueue.main.async {
                self.qiblaDirection = qibla.direction
                withAnimation(.easeInOut) {
                    self.prayerTimes = newItems
                }
                self.updateNextPrayerInfo(name: nextPrayerNameStr, time: nextPrayerDate)
                self.scheduleNotifications(for: newItems)
            }
        }
        
        // MARK: - Helper Functions (ADDED TO FIX ERRORS)
        
        private func prayerNameString(_ p: Prayer) -> String {
            switch p {
            case .fajr: return "Fajr"
            case .sunrise: return "Sunrise"
            case .dhuhr: return "Dhuhr"
            case .asr: return "Asr"
            case .maghrib: return "Maghrib"
            case .isha: return "Isha"
            }
        }
        
        private func updateNextPrayerInfo(name: String, time: Date) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            self.nextPrayerTime = formatter.string(from: time)
            self.nextPrayerName = name
        }
    // MARK: - Notifications
    
    private func scheduleNotifications(for prayers: [PrayerItem]) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        for prayer in prayers {
            if prayer.time < Date() { continue }
            
            let content = UNMutableNotificationContent()
            content.title = prayer.name
            content.body = "It's time for \(prayer.name) prayer"
            
            // UPDATED: Use the custom adhan sound
            // Note: iOS limits notification sounds to 30 seconds.
            // If adhan.mp3 is longer, iOS will cut it off or use the default sound.
            content.sound = UNNotificationSound(named: UNNotificationSoundName("adhan.mp3"))
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: prayer.time)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: prayer.name, content: content, trigger: trigger)
            center.add(request)
        }
    }
}
