
//
//  TasbihView.swift
//  iPrayer
//
//  Created by Youssef Keram on 11/24/25.
//

import SwiftUI

struct TasbihView: View {
    @AppStorage("tasbihCount") private var count: Int = 0
    @State private var isTapped: Bool = false
    
    // The cycle length for the visual ring (usually 33 for SubhanAllah, etc.)
    let cycleTarget = 33
    
    var progress: CGFloat {
        return CGFloat(count % cycleTarget) / CGFloat(cycleTarget)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background Gradient
                LinearGradient(gradient: Gradient(colors: [Color(hex: "0F2027"), Color(hex: "203A43"), Color(hex: "2C5364")]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 40) {
                    // Header
                    HStack {
                        Text("Tasbih")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Spacer()
                        
                        // Reset Button
                        Button(action: resetCounter) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.title3)
                                .foregroundColor(.white.opacity(0.8))
                                .padding(10)
                                .background(Color.white.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    // Main Interaction Button
                    Button(action: incrementCounter) {
                        ZStack {
                            // 1. Outer Glow
                            Circle()
                                .fill(Color.teal.opacity(0.1))
                                .frame(width: 280, height: 280)
                                .blur(radius: 20)
                            
                            // 2. Background Circle
                            Circle()
                                .fill(Material.ultraThinMaterial)
                                .frame(width: 250, height: 250)
                                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                            
                            // 3. Progress Ring Track
                            Circle()
                                .stroke(Color.white.opacity(0.1), lineWidth: 15)
                                .frame(width: 250, height: 250)
                            
                            // 4. Active Progress Ring (Teal)
                            Circle()
                                .trim(from: 0.0, to: progress == 0 && count > 0 ? 1.0 : progress)
                                .stroke(
                                    AngularGradient(gradient: Gradient(colors: [.teal.opacity(0.6), .teal]), center: .center),
                                    style: StrokeStyle(lineWidth: 15, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                                .frame(width: 250, height: 250)
                                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: count)
                            
                            // 5. Counter Text
                            VStack(spacing: 5) {
                                Text("\(count)")
                                    .font(.system(size: 60, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white)
                                    .contentTransition(.numericText(countsDown: false))
                                
                                Text("cycle of 33")
                                    .font(.caption)
                                    .textCase(.uppercase)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .buttonStyle(ScaleButtonStyle()) // Apply custom bounce animation
                    
                    Spacer()
                    
                    Text("Tap anywhere on the circle")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.bottom, 30)
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Actions
    
    private func incrementCounter() {
        // Haptic Feedback (Heavy click feel)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        
        // Increment
        withAnimation {
            count += 1
        }
        
        // Special feedback when cycle completes
        if count % cycleTarget == 0 && count != 0 {
            let heavy = UIImpactFeedbackGenerator(style: .heavy)
            heavy.impactOccurred()
        }
    }
    
    private func resetCounter() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        withAnimation {
            count = 0
        }
    }
}

// Custom Button Style for the Bounce Effect
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
