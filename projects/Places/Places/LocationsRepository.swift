//
//  LocationsRepository.swift
//  Places
//
//  Created by Frans Glorie on 03/09/2026.
//

import Foundation

struct RemoteLocationsRepository: LocationsRepository {
    private let url: URL
    private let urlSession: URLSession
    private let decoder: JSONDecoder

    nonisolated init(
        url: URL = URL(string: "https://raw.githubusercontent.com/abnamrocoesd/assignment-ios/main/locations.json")!,
        urlSession: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.url = url
        self.urlSession = urlSession
        self.decoder = decoder
    }

    nonisolated func fetchLocations() async throws -> [Location] {
        let (data, response) = try await urlSession.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let locationsResponse = try decoder.decode(Locations.self, from: data)
        return locationsResponse.locations
    }
}
