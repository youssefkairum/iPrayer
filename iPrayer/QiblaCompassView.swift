//
//  QiblaCompassView.swift
//  iPrayer
//
//  Created by Youssef Keram on 11/23/25.
//

import SwiftUI

struct QiblaCompassView: View {
    @EnvironmentObject var viewModel: PrayerViewModel
    
    // Constants for layout
    let dialSize: CGFloat = 300
    let outerRingWidth: CGFloat = 30
    
    // Logic to determine if pointing at Qibla (within 5 degrees)
    var isFacingQibla: Bool {
        let difference = abs(viewModel.currentHeading - viewModel.qiblaDirection)
        let adjustedDifference = min(difference, 360 - difference)
        return adjustedDifference < 5
    }
    
    // Rotations
    var northRotation: Double {
        -viewModel.currentHeading
    }
    
    var qiblaRotation: Double {
        viewModel.qiblaDirection - viewModel.currentHeading
    }
    
    var body: some View {
        ZStack {
            // 1. Background (App Theme Dark Blue)
            LinearGradient(gradient: Gradient(colors: [Color(hex: "0F2027"), Color(hex: "203A43"), Color(hex: "2C5364")]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            // 2. Main Content
            VStack(spacing: 60) {
                Spacer()

                ZStack {
                    // A. Outer Glow Ring (Teal instead of Green)
                    Circle()
                        .stroke(isFacingQibla ? Color.teal.opacity(0.6) : Color.clear, lineWidth: 20)
                        .frame(width: dialSize + 10, height: dialSize + 10)
                        .blur(radius: 15)
                        .animation(.easeInOut, value: isFacingQibla)
                    
                    // B. Main White Dial Ring
                    Circle()
                        .stroke(Color.white, lineWidth: outerRingWidth)
                        .frame(width: dialSize, height: dialSize)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                    
                    // C. Inner Background (Teal Tint)
                    Circle()
                        .fill(Color.teal.opacity(0.2)) // Subtle Blue/Teal background
                        .frame(width: dialSize - outerRingWidth, height: dialSize - outerRingWidth)
                        .overlay(
                            // Placeholder for Islamic Pattern
                            Image(systemName: "star.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 150)
                                .foregroundColor(.teal.opacity(0.1))
                        )

                    // D. Degree Markers & Direction Labels
                    ForEach(0..<12) { i in
                        VStack {
                            Rectangle()
                                .fill(Color.white)
                                .frame(width: 2, height: i % 3 == 0 ? 15 : 10)
                            Spacer()
                        }
                        .frame(height: dialSize - 5)
                        .rotationEffect(.degrees(Double(i) * 30))
                    }
                    
                    // Labels
                    Group {
                        Text("N").position(x: dialSize/2, y: outerRingWidth/2).foregroundColor(.red)
                        Text("E").position(x: dialSize - outerRingWidth/2, y: dialSize/2)
                        Text("S").position(x: dialSize/2, y: dialSize - outerRingWidth/2)
                        Text("W").position(x: outerRingWidth/2, y: dialSize/2)
                    }
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: dialSize, height: dialSize)

                    // E. North Compass Needle (Red/White Standard)
                    Rectangle()
                        .fill(LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: .red, location: 0.0),
                                .init(color: .red, location: 0.5),
                                .init(color: .white.opacity(0.8), location: 0.5),
                                .init(color: .white.opacity(0.8), location: 1.0)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                        .frame(width: 16, height: dialSize - outerRingWidth - 20)
                        .clipShape(NeedleShape())
                        .shadow(radius: 3)
                        .rotationEffect(.degrees(northRotation))
                        .animation(.easeInOut(duration: 0.2), value: northRotation)

                    // F. Qibla Indicator (Golden/Teal Pointer)
                    VStack {
                        // The Arrow Tip
                        Image(systemName: "arrowtriangle.up.fill")
                            .resizable()
                            .frame(width: 14, height: 14)
                            .foregroundColor(isFacingQibla ? .teal : .white) // Teal when locked
                        
                        // The Kaaba Icon Wrapper
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 40, height: 40)
                                .shadow(color: isFacingQibla ? .teal.opacity(0.8) : .black.opacity(0.2), radius: isFacingQibla ? 15 : 3)
                            
                            // Placeholder Kaaba Icon
                            Image(systemName: "cube.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                                .foregroundColor(.black)
                        }
                        
                        Spacer()
                    }
                    .frame(height: dialSize + 50) // extend slightly beyond ring
                    .rotationEffect(.degrees(qiblaRotation))
                    .animation(.spring(response: 0.6, dampingFraction: 0.5), value: qiblaRotation)

                    // G. Center Pivot
                    Circle()
                        .fill(Color.white)
                        .frame(width: 12, height: 12)
                        .shadow(radius: 2)
                }
                
                Spacer()
                
                // 3. Status Text (Teal Text)
                Text(isFacingQibla ? "You're facing Mecca" : "Turn to face Mecca")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(isFacingQibla ? .teal : .white.opacity(0.7))
                    .padding(.bottom, 50)
                    .animation(.easeInOut, value: isFacingQibla)
            }
        }
        .onAppear {
            viewModel.startCompass()
        }
        .onDisappear {
            viewModel.stopCompass()
        }
    }
}

// Custom shape for the compass needle
struct NeedleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY)) // Top
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY)) // Right Mid
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY)) // Bottom
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY)) // Left Mid
        path.closeSubpath()
        return path
    }
}
