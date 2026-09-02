#  Wikipedia-places Assignment ReadMe file
By Frans Glorie, September 2026

Architecture outline:
- SwiftUI-app
- Swift Concurrency (Swift 6 + strict checking)
- View and viewModel for Locations, both MainActor
- Repository for Locations, conforming to a protocol for testability
- Tests using SwiftTesting, using mock data and repository stub
- Some accessibility (dynamic type, maybe colorscheme, maybe more)


Out of scope:
- No coordinator: a bit over the top
- No localization: same

Branching strategy:
- Just a development branch, no feature branches
- Frequent commits
