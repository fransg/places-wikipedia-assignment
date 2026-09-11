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

    @MainActor
    @Test func addLocationAppendsLocation() async throws {
        let viewModel = LocationsViewModel(
            repository: StubLocationsRepository(result: .success([]))
        )
        let location = Location(name: "Utrecht", lat: 52.0907, long: 5.1214)

        viewModel.addLocation(location)

        #expect(viewModel.locations.count == 1)
        #expect(viewModel.locations[0].name == "Utrecht")
        #expect(viewModel.locations[0].lat == 52.0907)
        #expect(viewModel.locations[0].long == 5.1214)
    }

    @MainActor
    @Test func addLocationFromInputAppendsLocationAndClearsInput() async throws {
        let viewModel = LocationsViewModel(
            repository: StubLocationsRepository(result: .success([]))
        )
        viewModel.addLocationName = "Greenland"
        viewModel.addLocationLatitude = "76.390857"
        viewModel.addLocationLongitude = "-40.707943"

        let didAddLocation = viewModel.addLocationFromInput()

        #expect(didAddLocation)
        #expect(viewModel.locations.count == 1)
        #expect(viewModel.locations[0].name == "Greenland")
        #expect(viewModel.locations[0].lat == 76.390857)
        #expect(viewModel.locations[0].long == -40.707943)
        #expect(viewModel.addLocationName.isEmpty)
        #expect(viewModel.addLocationLatitude.isEmpty)
        #expect(viewModel.addLocationLongitude.isEmpty)
        #expect(viewModel.addLocationErrors.isEmpty)
    }

    @MainActor
    @Test func addLocationFromInputRejectsDuplicateName() async throws {
        let viewModel = LocationsViewModel(
            repository: StubLocationsRepository(result: .success([]))
        )
        viewModel.addLocation(Location(name: "Greenland", lat: 76.390857, long: -40.707943))
        viewModel.addLocationName = "greenland"
        viewModel.addLocationLatitude = "70"
        viewModel.addLocationLongitude = "-40"

        let didAddLocation = viewModel.addLocationFromInput()

        #expect(didAddLocation == false)
        #expect(viewModel.locations.count == 1)
        #expect(viewModel.addLocationErrors.name == "A location with this name already exists.")
    }

    @MainActor
    @Test func addLocationFromInputRejectsOutOfRangeCoordinates() async throws {
        let viewModel = LocationsViewModel(
            repository: StubLocationsRepository(result: .success([]))
        )
        viewModel.addLocationName = "Invalid Coordinates"
        viewModel.addLocationLatitude = "91"
        viewModel.addLocationLongitude = "-181"

        let didAddLocation = viewModel.addLocationFromInput()

        #expect(didAddLocation == false)
        #expect(viewModel.locations.isEmpty)
        #expect(viewModel.addLocationErrors.latitude == "Latitude must be between -90 and 90.")
        #expect(viewModel.addLocationErrors.longitude == "Longitude must be between -180 and 180.")
    }

    @MainActor
    @Test func deleteLocationsRemovesLocationsAtOffsets() async throws {
        let viewModel = LocationsViewModel(
            repository: StubLocationsRepository(result: .success([]))
        )
        viewModel.addLocation(Location(name: "Amsterdam", lat: 52.354297, long: 4.919669))
        viewModel.addLocation(Location(name: "Castricum", lat: 52.550292, long: 4.669685))
        viewModel.addLocation(Location(name: "Utrecht", lat: 52.0907, long: 5.1214))

        viewModel.deleteLocations(at: IndexSet(integer: 1))

        #expect(viewModel.locations.count == 2)
        #expect(viewModel.locations[0].name == "Amsterdam")
        #expect(viewModel.locations[1].name == "Utrecht")
    }

    @MainActor
    @Test func selectLocationOpensLocationInWikipedia() async throws {
        let locationOpener = StubLocationOpener(result: true)
        let viewModel = LocationsViewModel(
            repository: StubLocationsRepository(result: .success([])),
            locationOpener: locationOpener
        )
        let location = Location(name: "Greenland", lat: 76.390857, long: -40.707943)

        viewModel.selectLocation(location)

        #expect(locationOpener.openedLocations.count == 1)
        #expect(locationOpener.openedLocations[0].name == "Greenland")
        #expect(locationOpener.openedLocations[0].lat == 76.390857)
        #expect(locationOpener.openedLocations[0].long == -40.707943)
        #expect(viewModel.isShowingCannotOpenWikipediaAlert == false)
    }

    @MainActor
    @Test func selectLocationShowsAlertWhenWikipediaCannotBeOpened() async throws {
        let locationOpener = StubLocationOpener(result: false)
        let viewModel = LocationsViewModel(
            repository: StubLocationsRepository(result: .success([])),
            locationOpener: locationOpener
        )

        viewModel.selectLocation(Location(name: "Greenland", lat: 76.390857, long: -40.707943))

        #expect(locationOpener.openedLocations.count == 1)
        #expect(viewModel.isShowingCannotOpenWikipediaAlert)
    }

    @Test func remoteRepositoryFetchesLocations() async throws {
        let json = """
        {
            "locations": [
                {
                    "name": "Amsterdam",
                    "lat": 52.354297,
                    "long": 4.919669
                },
                {
                    "name": "Castricum",
                    "lat": 52.550292,
                    "long": 4.669685
                }
            ]
        }
        """.data(using: .utf8)!
        let url = URL(string: "https://example.com/success-locations.json")!
        let repository = RemoteLocationsRepository(
            url: url,
            urlSession: .mock(url: url, data: json, statusCode: 200)
        )

        let locations = try await repository.fetchLocations()

        #expect(locations.count == 2)
        #expect(locations[0].name == "Amsterdam")
        #expect(locations[0].lat == 52.354297)
        #expect(locations[0].long == 4.919669)
        #expect(locations[1].name == "Castricum")
    }

    @Test func remoteRepositoryThrowsForUnsuccessfulStatusCode() async throws {
        let url = URL(string: "https://example.com/server-error.json")!
        let repository = RemoteLocationsRepository(
            url: url,
            urlSession: .mock(url: url, data: Data(), statusCode: 500)
        )

        await #expect(throws: URLError.self) {
            try await repository.fetchLocations()
        }
    }

    @Test func remoteRepositoryThrowsForInvalidJSON() async throws {
        let url = URL(string: "https://example.com/invalid-json.json")!
        let repository = RemoteLocationsRepository(
            url: url,
            urlSession: .mock(url: url, data: Data("invalid json".utf8), statusCode: 200)
        )

        await #expect(throws: DecodingError.self) {
            try await repository.fetchLocations()
        }
    }
}

private struct StubLocationsRepository: LocationsRepository {
    let result: Result<[Location], Error>

    func fetchLocations() async throws -> [Location] {
        try result.get()
    }
}

private final class StubLocationOpener: LocationOpening {
    private let result: Bool
    private(set) var openedLocations: [Location] = []

    init(result: Bool) {
        self.result = result
    }

    func openWikipedia(for location: Location) -> Bool {
        openedLocations.append(location)
        return result
    }
}

private final class MockURLProtocol: URLProtocol {
    // Protecting this mutable shared state by using Actor or MainActor would have undesirable consequences. So handling this low level.
    nonisolated(unsafe) private static var responses: [URL: (data: Data, statusCode: Int)] = [:]
    private static let lock = NSLock()

    static func register(data: Data, statusCode: Int, for url: URL) {
        lock.withLock {
            responses[url] = (data, statusCode)
        }
    }

    private static func response(for url: URL) -> (data: Data, statusCode: Int)? {
        lock.withLock {
            responses[url]
        }
    }

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let url = request.url,
              let response = Self.response(for: url),
              let httpResponse = HTTPURLResponse(
                url: url,
                statusCode: response.statusCode,
                httpVersion: nil,
                headerFields: nil
              ) else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }

        client?.urlProtocol(self, didReceive: httpResponse, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: response.data)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

private extension URLSession {
    static func mock(url: URL, data: Data, statusCode: Int) -> URLSession {
        MockURLProtocol.register(data: data, statusCode: statusCode, for: url)

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: configuration)
    }
}
