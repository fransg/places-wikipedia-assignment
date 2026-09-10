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

    func addLocation(_ location: Location) {
        locations.append(location)
    }

    func deleteLocations(at offsets: IndexSet) {
        for offset in offsets.sorted(by: >) {
            locations.remove(at: offset)
        }
    }
    
    func formatCoordinates(latitude: Double, longitude: Double) -> String {
        "\(formatCoordinate(latitude)); \(formatCoordinate(longitude))"
    }
    
    func formatAccessibilityCoordinates(latitude: Double, longitude: Double) -> String {
        "Latitude \(formatCoordinate(latitude)); longitude \(formatCoordinate(longitude))"
    }
    
    func formatCoordinate(_ coordinate: Double) -> String {
        coordinate.formatted(.number.precision(.fractionLength(6)))
    }
    
    func parseCoordinate(_ text: String) -> Double? {
        let trimmedText = text.trimmed
        
        if let number = coordinateFormatter.number(from: trimmedText) {
            return number.doubleValue
        }
        
        return Double(trimmedText.replacingOccurrences(of: ",", with: "."))
    }
    
    private let coordinateFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = .current
        return formatter
    }()
}
