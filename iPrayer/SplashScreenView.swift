//
//  SplashScreenView.swift
//  iPrayer
//
//  Created by Youssef Keram on 11/26/25.
//

import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        ZStack {
            // 1. Background (Same as App Theme)
            LinearGradient(gradient: Gradient(colors: [Color(hex: "0F2027"), Color(hex: "203A43"), Color(hex: "2C5364")]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                // 2. App Icon & Name
                VStack(spacing: 20) {
                    // Fetch the actual App Icon from the Bundle
                    if let icon = Bundle.main.icon {
                        Image(uiImage: icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120)
                            .cornerRadius(25) // iOS Icon corner radius style
                            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    } else {
                        // Fallback if no icon is found (Preview mode)
                        Image(systemName: "moon.stars.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .foregroundColor(.teal)
                            .frame(width: 120, height: 120)
                            .background(Material.ultraThinMaterial)
                            .cornerRadius(25)
                    }
                    
                    Text("iPrayer")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 5)
                }
                
                Spacer()
                
                // 3. Copyright Footer
                Text("COPYRIGHT 2025 Youssef Keram all rights reserved")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Helper to Fetch Default App Icon
extension Bundle {
    var icon: UIImage? {
        if let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
           let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
           let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
           let lastIcon = iconFiles.last {
            return UIImage(named: lastIcon)
        }
        return nil
    }
}
