#  Wikipedia-places Assignment ReadMe file
By Frans Glorie, September 2026

Architecture outline:
- SwiftUI-app
- Swift Concurrency (Swift 6 + strict checking)
- View and viewModel for Locations, both MainActor
- Repository for Locations, conforming to a protocol for testability
- Tests using SwiftTesting, using mock data and repository stub
- Some accessibility (dynamic type, maybe colorscheme, maybe more)
- Composition root? tbd


Out of scope:
- No coordinator: a bit over the top
- No localization: same
- No persistence (e.g. SwiftData)

Branching strategy:
- Just a development branch, no feature branches
- Frequent commits


Plan:
v Remote repository
v Remote repo tests
- View (re-use ContentView?)
- Link to Wikipedia
- Wikipedia-app:
  - Receive link
  - Perform navigation to Places tab and position map to received location.
- Some accessibility features

Decide:
- Support dark mode or not?
- Orientations to support? Just portrait?
