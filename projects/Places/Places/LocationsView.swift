//
//  LocationsView.swift
//  Places
//
//  Created by Frans Glorie on 02/09/2026.
//

import SwiftUI

struct LocationsView: View {
    
    @State private var viewModel = LocationsViewModel(repository: RemoteLocationsRepository())
    @State private var isShowingCannotOpenWikipediaAlert = false
    
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
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
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
        .alert("Cannot open Wikipedia", isPresented: $isShowingCannotOpenWikipediaAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("The Wikipedia app could not be opened. Please make sure the modified Wikipedia app is installed.")
        }
    }
    
    private func onSelectLocation(_ location: Location) {
        print("Tapped location: \(location)")
        
        guard let url = URL(string: "wikipedia-places://openPlace?lat=\(location.lat)&long=\(location.long)") else {
            return
        }

        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            isShowingCannotOpenWikipediaAlert = true
        }
    }
}

#Preview {
    LocationsView()
}
