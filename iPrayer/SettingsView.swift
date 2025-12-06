//
//  SettingsView.swift
//  iPrayer
//
//  Created by Youssef Keram on 11/24/25.
//

import SwiftUI

struct SettingsView: View {
    // 1. Persist settings automatically using AppStorage
    @AppStorage("calculationMethod") private var calculationMethodValue: String = "muslimWorldLeague"
    @AppStorage("madhab") private var madhabValue: String = "shafi" // 'shafi' is Standard (Maliki, Hanbali, Shafi)
    
    // Trigger updates when settings change
    @EnvironmentObject var viewModel: PrayerViewModel

    var body: some View {
        NavigationView {
            ZStack {
                // Background Gradient
                LinearGradient(gradient: Gradient(colors: [Color(hex: "0F2027"), Color(hex: "203A43"), Color(hex: "2C5364")]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    // Header
                    Text("Settings")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    Form {
                        Section(header: Text("Prayer Calculation").foregroundColor(.teal)) {
                            // Calculation Method Picker
                            Picker("Method", selection: $calculationMethodValue) {
                                Text("Muslim World League").tag("muslimWorldLeague")
                                Text("Egyptian General Authority").tag("egyptian")
                                Text("Karachi").tag("karachi")
                                Text("Umm Al-Qura (Makkah)").tag("ummAlQura")
                                Text("Dubai").tag("dubai")
                                Text("North America (ISNA)").tag("northAmerica")
                                Text("Kuwait").tag("kuwait")
                                Text("Qatar").tag("qatar")
                                Text("Singapore").tag("singapore")
                                Text("Turkey").tag("turkey")
                                Text("Tehran").tag("tehran")
                            }
                            .pickerStyle(NavigationLinkPickerStyle())
                            
                            // Madhab Picker
                            Picker("Juristic Method (Madhab)", selection: $madhabValue) {
                                Text("Standard (Shafi, Maliki, Hanbali)").tag("shafi")
                                Text("Hanafi").tag("hanafi")
                            }
                        }
                        .listRowBackground(Color(hex: "203A43").opacity(0.6))
                        
                        Section(header: Text("About").foregroundColor(.teal)) {
                            HStack {
                                Text("Version")
                                Spacer()
                                Text("1.0.0")
                                    .foregroundColor(.gray)
                            }
                            Link("Privacy Policy", destination: URL(string: "https://apple.com")!)
                                .foregroundColor(.white)
                        }
                        .listRowBackground(Color(hex: "203A43").opacity(0.6))
                    }
                    .scrollContentBackground(.hidden) // Makes the form transparent
                    .accentColor(.teal)
                }
            }
            .navigationBarHidden(true)
            // MARK: - iOS 17+ Fixed Syntax
            // We use { _, _ in } because we don't need the specific values,
            // we just need to know that *something* changed to trigger a refresh.
            .onChange(of: calculationMethodValue) { _, _ in
                viewModel.refreshPrayers()
            }
            .onChange(of: madhabValue) { _, _ in
                viewModel.refreshPrayers()
            }
        }
    }
}
