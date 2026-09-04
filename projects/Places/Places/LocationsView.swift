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
    @State private var isShowingAddLocation = false
    
    var body: some View {
        VStack {
            List {
                ForEach(viewModel.locations, id: \.name) { location in
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
                .onDelete { offsets in
                    viewModel.deleteLocations(at: offsets)
                }
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
                    isShowingAddLocation = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityIdentifier("AddLocation")
                .accessibilityLabel("Add location")
            }
        }
        .sheet(isPresented: $isShowingAddLocation) {
            NavigationStack {
                AddLocationView(existingLocations: viewModel.locations) { location in
                    viewModel.addLocation(location)
                    isShowingAddLocation = false
                } onCancel: {
                    isShowingAddLocation = false
                }
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

private struct AddLocationView: View {
    let existingLocations: [Location]
    let onAdd: (Location) -> Void
    let onCancel: () -> Void

    @State private var name = ""
    @State private var latitude = ""
    @State private var longitude = ""
    @State private var hasSubmitted = false

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var nameError: String? {
        if trimmedName.isEmpty {
            return "Name is required."
        }

        if existingLocations.contains(where: { $0.name?.localizedCaseInsensitiveCompare(trimmedName) == .orderedSame }) {
            return "A location with this name already exists."
        }

        return nil
    }

    private var latitudeValue: Double? {
        Double(latitude.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    private var latitudeError: String? {
        guard let latitudeValue else {
            return "Latitude must be a number."
        }

        if !(-90...90).contains(latitudeValue) {
            return "Latitude must be between -90 and 90."
        }

        return nil
    }

    private var longitudeValue: Double? {
        Double(longitude.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    private var longitudeError: String? {
        guard let longitudeValue else {
            return "Longitude must be a number."
        }

        if !(-180...180).contains(longitudeValue) {
            return "Longitude must be between -180 and 180."
        }

        return nil
    }

    private var isValid: Bool {
        nameError == nil && latitudeError == nil && longitudeError == nil
    }

    var body: some View {
        Form {
            Section("Please fill in the details:") {
                VStack(alignment: .leading, spacing: 4) {
                    TextField("Name", text: $name)
                        .textInputAutocapitalization(.words)
                        .accessibilityIdentifier("CustomLocationName")

                    validationText(nameError)
                }

                VStack(alignment: .leading, spacing: 4) {
                    TextField("Latitude", text: $latitude)
                        .keyboardType(.numbersAndPunctuation)
                        .accessibilityIdentifier("CustomLocationLatitude")

                    validationText(latitudeError)
                }

                VStack(alignment: .leading, spacing: 4) {
                    TextField("Longitude", text: $longitude)
                        .keyboardType(.numbersAndPunctuation)
                        .accessibilityIdentifier("CustomLocationLongitude")

                    validationText(longitudeError)
                }
            }
        }
        .navigationTitle("Add Location")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", role: .cancel) {
                    onCancel()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Add") {
                    addLocation()
                }
            }
        }
    }

    @ViewBuilder
    private func validationText(_ text: String?) -> some View {
        if hasSubmitted, let text {
            Text(text)
                .font(.caption)
                .foregroundStyle(.red)
                .accessibilityLabel(text)
        }
    }

    private func addLocation() {
        hasSubmitted = true

        guard isValid,
              let latitudeValue,
              let longitudeValue else {
            return
        }

        onAdd(Location(name: trimmedName, lat: latitudeValue, long: longitudeValue))
    }
}

#Preview {
    LocationsView()
}
