//
//  LocationsView.swift
//  Places
//
//  Created by Frans Glorie on 02/09/2026.
//

import SwiftUI

struct LocationsView: View {
    
    @State private var viewModel: LocationsViewModel
    @State private var isShowingCannotOpenWikipediaAlert = false
    @State private var isShowingAddLocation = false
    
    init(viewModel: LocationsViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            locationsList

            if viewModel.locations.isEmpty && !viewModel.isLoading {
                ContentUnavailableView(
                    "No Locations",
                    systemImage: "mappin.slash",
                    description: Text("Tap Add to create a custom location.")
                )
            }

            if viewModel.isLoading {
                ProgressView("Loading locations")
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .accessibilityIdentifier("LocationsLoadingIndicator")
            }
        }
        .task {
            await viewModel.loadLocations()
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
                AddLocationView(
                    existingLocations: viewModel.locations,
                    onAdd: { location in
                        viewModel.addLocation(location)
                        isShowingAddLocation = false
                    },
                    onCancel: {
                        isShowingAddLocation = false
                    },
                    viewModel: viewModel
                )
            }
        }
        .alert("Cannot open Wikipedia", isPresented: $isShowingCannotOpenWikipediaAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("The Wikipedia app could not be opened. Please make sure the modified Wikipedia app is installed.")
        }
    }
    
    private var locationsList: some View {
        List {
            ForEach(viewModel.locations, id: \.name) { location in
                Button {
                    onSelectLocation(location)
                } label: {
                    VStack(alignment: .leading) {
                        Text(location.name ?? "Unnamed location")
                            .foregroundStyle(.primary)
                            .accessibilityIdentifier("LocationName")
                        
                        Text(viewModel.formatCoordinates(latitude: location.lat, longitude: location.long))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .accessibilityIdentifier("LocationCoordinates")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(location.name ?? "Unnamed location")
                .accessibilityValue(viewModel.formatAccessibilityCoordinates(latitude: location.lat, longitude: location.long))
                .accessibilityHint("Opens this location in Wikipedia")
            }
            .onDelete { offsets in
                viewModel.deleteLocations(at: offsets)
            }
        }
        .refreshable {
            await viewModel.loadLocations()
        }
    }
    
    private func onSelectLocation(_ location: Location) {
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
    let viewModel: LocationsViewModel

    @State private var name = ""
    @State private var latitude = ""
    @State private var longitude = ""
    @State private var hasSubmitted = false
    @AccessibilityFocusState private var focusedField: Field?

    private enum Field: Hashable {
        case name
        case latitude
        case longitude
    }

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
        viewModel.parseCoordinate(latitude)
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
        viewModel.parseCoordinate(longitude)
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
                        .accessibilityFocused($focusedField, equals: .name)

                    validationText(nameError)
                }

                VStack(alignment: .leading, spacing: 4) {
                    TextField("Latitude", text: $latitude)
                        .keyboardType(.numbersAndPunctuation)
                        .accessibilityIdentifier("CustomLocationLatitude")
                        .accessibilityHint("Enter a value between -90 and 90")
                        .accessibilityFocused($focusedField, equals: .latitude)

                    validationText(latitudeError)
                }

                VStack(alignment: .leading, spacing: 4) {
                    TextField("Longitude", text: $longitude)
                        .keyboardType(.numbersAndPunctuation)
                        .accessibilityIdentifier("CustomLocationLongitude")
                        .accessibilityHint("Enter a value between -180 and 180")
                        .accessibilityFocused($focusedField, equals: .longitude)

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

    // FG Remarks after review: most of the logic below should have gone into a viewModel instead.
    
    private func addLocation() {
        hasSubmitted = true

        guard isValid,
              let latitudeValue,
              let longitudeValue else {
            focusFirstInvalidField()
            return
        }

        onAdd(Location(name: trimmedName, lat: latitudeValue, long: longitudeValue))
    }

    private func focusFirstInvalidField() {
        if nameError != nil {
            focusedField = .name
        } else if latitudeError != nil {
            focusedField = .latitude
        } else if longitudeError != nil {
            focusedField = .longitude
        }
    }
    
}

#Preview {
    LocationsView(
        viewModel: LocationsViewModel(repository: RemoteLocationsRepository())
    )
}
