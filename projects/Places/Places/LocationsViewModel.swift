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

protocol LocationOpening {
    func openWikipedia(for location: Location) -> Bool
}

struct AddLocationErrors: Equatable, Error {
    var name: String?
    var latitude: String?
    var longitude: String?

    var isEmpty: Bool {
        name == nil && latitude == nil && longitude == nil
    }
}

struct AddLocationValidator {
    func validate(
        name: String,
        latitudeText: String,
        longitudeText: String,
        existingLocations: [Location]
    ) -> Result<Location, AddLocationErrors> {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        var errors = AddLocationErrors()

        if trimmedName.isEmpty {
            errors.name = "Name is required."
        } else if existingLocations.contains(where: {
            $0.name?.localizedCaseInsensitiveCompare(trimmedName) == .orderedSame
        }) {
            errors.name = "A location with this name already exists."
        }

        let latitude = parseCoordinate(latitudeText)
        if latitude == nil {
            errors.latitude = "Latitude must be a number."
        } else if !(-90...90).contains(latitude!) {
            errors.latitude = "Latitude must be between -90 and 90."
        }

        let longitude = parseCoordinate(longitudeText)
        if longitude == nil {
            errors.longitude = "Longitude must be a number."
        } else if !(-180...180).contains(longitude!) {
            errors.longitude = "Longitude must be between -180 and 180."
        }

        guard errors.isEmpty, let latitude, let longitude else {
            return .failure(errors)
        }

        return .success(
            Location(name: trimmedName, lat: latitude, long: longitude)
        )
    }
    
    private func parseCoordinate(_ text: String) -> Double? {
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

@MainActor
@Observable
final class LocationsViewModel {
    private let repository: LocationsRepository
    private let locationOpener: LocationOpening

    private(set) var locations: [Location] = []
    private(set) var isLoading = false
    var isShowingCannotOpenWikipediaAlert = false
    var errorMessage: String?
    
    var addLocationName = ""
    var addLocationLatitude = ""
    var addLocationLongitude = ""
    
    private var validator = AddLocationValidator()

    private(set) var addLocationErrors = AddLocationErrors()

    init(
        repository: LocationsRepository,
        locationOpener: LocationOpening = WikipediaLocationOpener()
    ) {
        self.repository = repository
        self.locationOpener = locationOpener
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

    func addLocationFromInput() -> Bool {
        let result = validator.validate(
            name: addLocationName,
            latitudeText: addLocationLatitude,
            longitudeText: addLocationLongitude,
            existingLocations: locations
        )

        switch result {
        case .success(let location):
            locations.append(location)
            clearAddLocationInput()
            return true

        case .failure(let errors):
            addLocationErrors = errors
            return false
        }
    }

    func addLocation(_ location: Location) {
        locations.append(location)
    }

    func selectLocation(_ location: Location) {
        isShowingCannotOpenWikipediaAlert = !locationOpener.openWikipedia(for: location)
    }
    
    private func clearAddLocationInput() {
        addLocationName = ""
        addLocationLatitude = ""
        addLocationLongitude = ""
        addLocationErrors = AddLocationErrors()
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
}
