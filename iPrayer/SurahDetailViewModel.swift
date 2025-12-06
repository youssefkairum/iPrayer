//
//  SurahDetailViewModel.swift
//  iPrayer
//
//  Created by Youssef Keram on 11/24/25.
//

import Foundation
import Combine

class SurahDetailViewModel: ObservableObject {
    @Published var verses: [Ayah] = []
    @Published var isLoading: Bool = true
    @Published var errorMessage: String? = nil
    
    func fetchVerses(for surahNumber: Int) {
        // We fetch the 'quran-uthmani' edition for the classic Arabic script
        let urlString = "https://api.alquran.cloud/v1/surah/\(surahNumber)/editions/quran-uthmani"
        guard let url = URL(string: urlString) else { return }
        
        isLoading = true
        verses = [] // Clear old data
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                guard let data = data else { return }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(SurahDetailResponse.self, from: data)
                    if let edition = decodedResponse.data.first {
                        self?.verses = edition.ayahs
                    }
                } catch {
                    self?.errorMessage = "Failed to load verses."
                    print("Detail decoding error: \(error)")
                }
            }
        }.resume()
    }
}
