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
v View (re-use ContentView?)
v Link to Wikipedia (sending side)
v Wikipedia-app: (note: follow wmf and other naming conventions in that app)
  v Receive link
  v Parse link and perform navigation to Places tab
  v Position map to received location.
- Add (and delete) locations, simple UI first, optionally using MapKit later
- Some accessibility features
- Polish
- Verify (feature complete? Bonus points? Cleanup any debugging code, regression test Wiki places link)

Decide:
- Support dark mode or not?
- Orientations to support? Just portrait?
- Whether to rename 'location' to 'place'. It feels inconsistent now.
