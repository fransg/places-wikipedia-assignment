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
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
                .padding(.bottom, 24)
            
            List(viewModel.locations, id: \.name) { location in
                VStack(alignment: .leading) {
                    Text(location.name ?? "Unnamed location")

                    Text("\(location.lat), \(location.long)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .task {
                await viewModel.loadLocations()
            }
        }
        .padding()
    }
}

#Preview {
    LocationsView()
}
