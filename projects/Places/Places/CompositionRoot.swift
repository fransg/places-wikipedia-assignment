//
//  CompositionRoot.swift
//  Places
//
//  Created by Frans Glorie on 04/09/2026.
//

import SwiftUI
import UIKit

struct WikipediaLocationOpener: LocationOpening {
    func openWikipedia(for location: Location) -> Bool {
        guard let url = URL(string: "wikipedia-places://openPlace?lat=\(location.lat)&long=\(location.long)") else {
            return false
        }

        guard UIApplication.shared.canOpenURL(url) else {
            return false
        }

        UIApplication.shared.open(url)
        return true
    }
}

@MainActor
final class CompositionRoot {
    static func makeLocationsView() -> LocationsView {
        let repository = RemoteLocationsRepository()
        let viewModel = LocationsViewModel(repository: repository)
        return LocationsView(viewModel: viewModel)
    }
}
