## Places
By Frans Glorie

A SwiftUI app that fetches interesting locations and opens the modified Wikipedia app for a selected coordinate.

## Features

- Fetches locations from the assignment JSON endpoint.
- Displays locations in a SwiftUI list.
- Opens the modified Wikipedia app through a custom URL scheme.
- Supports adding custom locations with validation.
- Supports swipe-to-delete.
- Shows loading and empty states.
- Includes basic VoiceOver accessibility support.

## Technical Notes

- Built with SwiftUI.
- Uses Swift Concurrency with `async/await`.
- Uses a repository protocol plus `RemoteLocationsRepository`.
- Uses an `@MainActor` observable view model for UI state.
- Uses a small `CompositionRoot` to construct dependencies.
- Locale-aware coordinate formatting/parsing.
- Custom app icon added.

## Accessibility

- Location rows expose VoiceOver labels, coordinate values, and action hints.
- The add-location form has field hints and inline validation messages.
- On invalid Add, accessibility focus moves to the first invalid field.
- Loading and empty states use accessible SwiftUI components.

## Testing

- Unit tests cover:
  - view model success/failure loading
  - adding a location
  - deleting locations
  - remote repository success, HTTP failure, and decoding failure
- UI test covers:
  - adding Greenland
  - verifying it appears
  - deleting it again
  - verifying it is removed

## Wikipedia Integration

The app opens URLs like:
wikipedia-places://openPlace?lat=52.354297&long=4.919669

## Building:
- Straightforward Xcode 26, no SPM or Cocoapod dependencies

## Running
1. Open `Places.xcodeproj`.
2. Select the `Places` scheme.
3. Run on an iOS Simulator or device.
4. To test Wikipedia opening, install/run the modified Wikipedia app that handles the `wikipedia-places` URL scheme. Or use simctl with for instance: wikipedia-places://openPlace?lat=55.6713442&long=12.523785

#  Wikipedia-places Assignment-specific
By Frans Glorie, September 2026

Architecture outline:
- SwiftUI-app
- Swift Concurrency (Swift 6 + strict checking)
- View and viewModel for Locations, both MainActor
- Repository for Locations, conforming to a protocol for testability
- Unit tests using SwiftTesting, using mock data and repository stub; UI-test using XCTest
- Some accessibility (dynamic type, voice over)
- Composition root

## Out of scope:
- No coordinator: a bit over the top
- No localization: same
- No persistence (e.g. SwiftData)

## Branching strategy:
- Just a development branch, no feature branches
- Frequent commits
- Modified Wikipedia app and new Places app together in a monorepo

## Developmemt plan:
v Model (entity) and viewModel
v Remote repository
v Remote repo tests
v View (re-use ContentView)
v Link to Wikipedia (sending side)
v Wikipedia-app: (note: follow wmf and other naming conventions in that app)
  v Receive link
  v Parse link and perform navigation to Places tab
  v Position map to received location.
v Add (and delete) locations, simple UI first, optionally using MapKit later
v Some accessibility features
  v Voice over on main page and Add Location dialog
  v Dynamic type (out of the box)
  v Accessibility identifiers (can be used by UI-test)
v Polish:
    v add composition root, app icon, handling nil name, isLoading state, handle empty state, point vs comma handling, add UI-test, make view refreshable
v Verify:
  v Feature complete
  v Bonus points (Swift Concurrency and Accessibility.. and a UI-test)
  v Cleanup any debugging code
  v Regression test Wiki places link
  v README complete and correct

## Decide:
v Support dark mode or not? A: Support out of the box dark mode and light mode
v Orientations to support? Just portrait? A: Any orientation supported, nothing breaks in landscape
v Whether to rename 'location' to 'place'. It feels inconsistent now. A: Keep as is: App is called Places, and it deals with Locations
v Validation on add location input:
    v Name mandatory and no duplicates allowed
    v Validate lat numeric -90..+90 and numeric long -180..+180, decimal point or comma accepted
