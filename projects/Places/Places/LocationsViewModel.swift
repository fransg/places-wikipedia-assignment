//
//  LocationsViewModel.swift
//  Places
//
//  Created by Frans Glorie on 02/09/2026.
//

import Foundation
import Observation

protocol LocationsRepository {
    func fetchLocations() async throws -> [Location]
}

@MainActor
@Observable
final class LocationsViewModel {
    private let repository: LocationsRepository

    private(set) var locations: [Location] = []
    private(set) var isLoading = false
    var errorMessage: String?

    init(repository: LocationsRepository) {
        self.repository = repository
    }

    func loadLocations() async {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            locations = try await repository.fetchLocations()
        } catch {
            locations = []
            errorMessage = "Could not load locations. Please try again."
        }
    }
}
