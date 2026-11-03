//
//  CountryListViewModel.swift
//  NextPro
//
//  Created by JYOTIRMOY PATRA on 02/11/26.
//

import Foundation
import Combine

@MainActor
final class CountryListViewModel: ObservableObject {

    static let countriesCacheKey = "cached_country_list"

    @Published private(set) var countries: [Country]
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isFailedDueToNoInternet = false

    private let networkManager = NetworkManager.shared

    init() {
        if let cachedData = UserDefaults.standard.data(forKey: Self.countriesCacheKey),
           let cachedCountries = try? JSONDecoder().decode([Country].self, from: cachedData) {
            countries = cachedCountries
        } else {
            countries = []
        }
    }

    func getCountryList(force: Bool = false) async {
        if !countries.isEmpty && !force { return }

        guard networkManager.hasInternet else {
            errorMessage = nil
            isFailedDueToNoInternet = true
            return
        }

        isFailedDueToNoInternet = false
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let response = try await networkManager.countryList()
            if response.status {
                countries = response.data
                if let encodedCountries = try? JSONEncoder().encode(response.data) {
                    UserDefaults.standard.set(encodedCountries, forKey: Self.countriesCacheKey)
                }
            } else {
                errorMessage = response.message.isEmpty ? "Something Went Wrong!" : response.message
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refreshCountries() async {
        await getCountryList(force: true)
    }
}
