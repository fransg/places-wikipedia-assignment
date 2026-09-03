//
//  LocationsView.swift
//  Places
//
//  Created by Frans Glorie on 02/09/2026.
//

import SwiftUI

struct LocationsView: View {
    
    @State private var viewModel = LocationsViewModel(repository: RemoteLocationsRepository())
    
    var body: some View {
        VStack {
            List(viewModel.locations, id: \.name) { location in
                Button {
                    onSelectLocation(location)
                } label: {
                    VStack(alignment: .leading) {
                        Text(location.name ?? "Unnamed location")
                            .foregroundStyle(.primary)
                            .accessibilityIdentifier("LocationName")
                        
                        Text("\(location.lat), \(location.long)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .accessibilityIdentifier("LocationCoordinates")
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(location.name ?? "Unnamed location")
                .accessibilityValue("Latitude \(location.lat), longitude \(location.long)")
                .accessibilityHint("Opens this location in Wikipedia")
            }
            .task {
                await viewModel.loadLocations()
            }
        }
        .padding(0)
        .navigationTitle("Locations")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    print("Tapped Add button")
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityIdentifier("AddLocation")
                .accessibilityLabel("Add location")
            }
        }
    }
    
    private func onSelectLocation(_ location: Location) {
        print("Tapped location: \(location)")
    }
}

#Preview {
    LocationsView()
}
