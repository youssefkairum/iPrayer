//
//  QuranViewModel.swift
//  iPrayer
//
//  Created by Youssef Keram on 11/24/25.
//

import Foundation
import Combine

class QuranViewModel: ObservableObject {
    @Published var surahs: [SurahMetadata] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    init() {
        fetchSurahList()
    }
    
    func fetchSurahList() {
        // Fetch metadata for all Surahs
        guard let url = URL(string: "https://api.alquran.cloud/v1/surah") else { return }
        
        isLoading = true
        errorMessage = nil
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "Failed to load Quran: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else { return }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(SurahListResponse.self, from: data)
                    self?.surahs = decodedResponse.data
                } catch {
                    self?.errorMessage = "Data format error."
                    print("Decoding error: \(error)")
                }
            }
        }.resume()
    }
}
