#  Wikipedia-places Assignment ReadMe file
By Frans Glorie, September 2026

Architecture outline:
- SwiftUI-app
- Swift Concurrency (Swift 6 + strict checking)
- View and viewModel for Locations, both MainActor
- Repository for Locations, conforming to a protocol for testability
- Tests using SwiftTesting, using mock data and repository stub
- Some accessibility (dynamic type, voice over)
- Composition root

Building:
- Straightforward Xcode 26, no SPM or Cocoapod dependencies

- Places app uses a scheme based link to the modified Wikipedia app in this repo, e.g.:
  wikipedia-places://openPlace?lat=55.6713442&long=12.523785

Out of scope:
- No coordinator: a bit over the top
- No localization: same
- No persistence (e.g. SwiftData)

Branching strategy:
- Just a development branch, no feature branches
- Frequent commits
- Modified Wikipedia app and new Places app together in a monorepo


Developmemt plan:
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
    v add composition root, app icon, handling nil name, isLoading state, handle empty state, point vs comma handling, add UI-test
- Verify:
  v Feature complete
  v Bonus points (Swift Concurrency and Accessibility.. and a UI-test)
  - Cleanup any debugging code
  - Regression test Wiki places link

Decide:
v Support dark mode or not? A: Support out of the box dark mode and light mode
v Orientations to support? Just portrait? A: Any orientation supported, nothing breaks in landscape
v Whether to rename 'location' to 'place'. It feels inconsistent now. A: Keep as is: App is called Places, and it deals with Locations
v Validation on add location input:
    v Name mandatory and no duplicates allowed
    v Validate lat numeric -90..+90 and numeric long -180..+180, decimal point or comma accepted
