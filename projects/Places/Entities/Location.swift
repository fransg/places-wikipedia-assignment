//
//  Location.swift
//  Places
//
//  Created by Frans Glorie on 02/09/2026.
//

import Foundation

// MARK: - Locations
nonisolated struct Locations: Codable {
    let locations: [Location]

    enum CodingKeys: String, CodingKey {
        case locations = "locations"
    }
}

// MARK: - Location
nonisolated struct Location: Codable {
    let name: String?
    let lat: Double
    let long: Double

    enum CodingKeys: String, CodingKey {
        case name = "name"
        case lat = "lat"
        case long = "long"
    }
}
