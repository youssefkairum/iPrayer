

//
//  QuranView.swift
//  iPrayer
//
//  Created by Youssef Keram on 11/24/25.
//

import SwiftUI

struct QuranView: View {
    @StateObject private var quranVM = QuranViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background Gradient
                LinearGradient(gradient: Gradient(colors: [Color(hex: "0F2027"), Color(hex: "203A43"), Color(hex: "2C5364")]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                if quranVM.isLoading {
                    ProgressView("Loading Quran...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .teal))
                        .foregroundColor(.white)
                } else if let error = quranVM.errorMessage {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text(error).foregroundColor(.white)
                        Button("Retry") { quranVM.fetchSurahList() }
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Header
                            Text("The Holy Quran")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.top, 20)
                            
                            // Surah List
                            LazyVStack(spacing: 15) {
                                ForEach(quranVM.surahs) { surah in
                                    NavigationLink(destination: SurahDetailView(surah: surah)) {
                                        SurahRow(surah: surah)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - List Row Component
struct SurahRow: View {
    let surah: SurahMetadata
    
    var body: some View {
        HStack {
            // Number Circle
            ZStack {
                Circle()
                    .stroke(Color.teal, lineWidth: 2)
                    .frame(width: 40, height: 40)
                
                Text("\(surah.number)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.teal)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(surah.englishName)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("\(surah.englishNameTranslation) • \(surah.numberOfAyahs) Verses")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text(surah.name)
                .font(.system(size: 22, weight: .bold, design: .serif))
                .foregroundColor(.teal)
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Reading View (Detail)
struct SurahDetailView: View {
    let surah: SurahMetadata
    @StateObject private var detailVM = SurahDetailViewModel()
    
    var body: some View {
        ZStack {
            Color(hex: "0F2027").edgesIgnoringSafeArea(.all)
            
            if detailVM.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .teal))
                    .scaleEffect(1.5)
            } else {
                ScrollView {
                    VStack(spacing: 25) {
                        // Title Header
                        VStack(spacing: 10) {
                            Text(surah.name)
                                .font(.system(size: 40, weight: .bold, design: .serif))
                                .foregroundColor(.teal)
                            
                            Text(surah.englishName)
                                .font(.title3)
                                .foregroundColor(.white.opacity(0.8))
                            
                            // Show Basmala (Except for Surah At-Tawbah #9 and Al-Fatiha #1 which has it as verse 1)
                            if surah.number != 9 && surah.number != 1 {
                                Text("بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ")
                                    .font(.system(size: 24, design: .serif))
                                    .foregroundColor(.teal.opacity(0.8))
                                    .padding(.top, 10)
                            }
                            
                            Divider()
                                .background(Color.gray.opacity(0.5))
                                .padding(.horizontal, 50)
                        }
                        .padding(.top, 20)
                        
                        // Verses List
                        VStack(spacing: 30) {
                            ForEach(detailVM.verses) { ayah in
                                VStack(spacing: 15) {
                                    Text(ayah.text)
                                        .font(.system(size: 26, weight: .regular, design: .serif))
                                        .multilineTextAlignment(.center)
                                        .lineSpacing(12)
                                        .foregroundColor(.white)
                                        .padding(.horizontal)
                                    
                                    // Verse Number Decoration
                                    HStack {
                                        Spacer()
                                        ZStack {
                                            Image(systemName: "seal")
                                                .resizable()
                                                .frame(width: 30, height: 30)
                                                .foregroundColor(.teal.opacity(0.6))
                                            
                                            Text("\(ayah.numberInSurah)")
                                                .font(.caption2)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                        }
                                        Spacer()
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 50)
                    }
                }
            }
        }
        .onAppear {
            detailVM.fetchVerses(for: surah.number)
        }
    }
}
