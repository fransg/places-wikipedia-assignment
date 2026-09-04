//
//  CompositionRoot.swift
//  Places
//
//  Created by Frans Glorie on 04/09/2026.
//

import SwiftUI

@MainActor
final class CompositionRoot {
    static func makeLocationsView() -> LocationsView {
        let repository = RemoteLocationsRepository()
        let viewModel = LocationsViewModel(repository: repository)
        return LocationsView(viewModel: viewModel)
    }
}
