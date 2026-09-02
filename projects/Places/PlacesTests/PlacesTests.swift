//
//  PlacesTests.swift
//  PlacesTests
//
//  Created by Frans Glorie on 02/09/2026.
//

import Foundation
import Testing
@testable import Places

struct PlacesTests {

    @MainActor
    @Test func loadLocationsPublishesFetchedLocations() async throws {
        let expectedLocations = [
            Location(name: "Amsterdam", lat: 52.354297, long: 4.919669),
            Location(name: "Castricum", lat: 52.550292, long: 4.669685)
        ]
        let viewModel = LocationsViewModel(
            repository: StubLocationsRepository(result: .success(expectedLocations))
        )

        await viewModel.loadLocations()

        #expect(viewModel.locations.count == 2)
        #expect(viewModel.locations[0].name == "Amsterdam")
        #expect(viewModel.locations[0].lat == 52.354297)
        #expect(viewModel.locations[0].long == 4.919669)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }

    @MainActor
    @Test func loadLocationsPublishesErrorWhenRepositoryFails() async throws {
        let viewModel = LocationsViewModel(
            repository: StubLocationsRepository(result: .failure(URLError(.notConnectedToInternet)))
        )

        await viewModel.loadLocations()

        #expect(viewModel.locations.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage != nil)
    }
}

private struct StubLocationsRepository: LocationsRepository {
    let result: Result<[Location], Error>

    func fetchLocations() async throws -> [Location] {
        try result.get()
    }
}
