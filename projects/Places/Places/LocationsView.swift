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
                    viewModel: viewModel,
                    onDismiss: {
                        isShowingAddLocation = false
                    }
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
    @Bindable var viewModel: LocationsViewModel
    let onDismiss: () -> Void

    @State private var hasSubmitted = false
    @AccessibilityFocusState private var focusedField: Field?

    private enum Field: Hashable {
        case name
        case latitude
        case longitude
    }

    var body: some View {
        Form {
            Section("Please fill in the details:") {
                VStack(alignment: .leading, spacing: 4) {
                    TextField("Name", text: $viewModel.addLocationName)
                        .textInputAutocapitalization(.words)
                        .accessibilityIdentifier("CustomLocationName")
                        .accessibilityFocused($focusedField, equals: .name)

                    validationText(viewModel.addLocationErrors.name)
                }

                VStack(alignment: .leading, spacing: 4) {
                    TextField("Latitude", text: $viewModel.addLocationLatitude)
                        .keyboardType(.numbersAndPunctuation)
                        .accessibilityIdentifier("CustomLocationLatitude")
                        .accessibilityHint("Enter a value between -90 and 90")
                        .accessibilityFocused($focusedField, equals: .latitude)

                    validationText(viewModel.addLocationErrors.latitude)
                }

                VStack(alignment: .leading, spacing: 4) {
                    TextField("Longitude", text: $viewModel.addLocationLongitude)
                        .keyboardType(.numbersAndPunctuation)
                        .accessibilityIdentifier("CustomLocationLongitude")
                        .accessibilityHint("Enter a value between -180 and 180")
                        .accessibilityFocused($focusedField, equals: .longitude)

                    validationText(viewModel.addLocationErrors.longitude)
                }
            }
        }
        .navigationTitle("Add Location")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", role: .cancel) {
                    onDismiss()
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

        if viewModel.addLocationFromInput() {
            onDismiss()
        } else {
            focusFirstInvalidField()
        }
    }

    private func focusFirstInvalidField() {
        if viewModel.addLocationErrors.name != nil {
            focusedField = .name
        } else if viewModel.addLocationErrors.latitude != nil {
            focusedField = .latitude
        } else if viewModel.addLocationErrors.longitude != nil {
            focusedField = .longitude
        }
    }
}

#Preview {
    LocationsView(
        viewModel: LocationsViewModel(repository: RemoteLocationsRepository())
    )
}
