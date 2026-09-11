# ABN AMRO iOS Assignment

**Update 2026-09-11: Updated Places-app after receiving assignment feedback. Better separation between view and viewModel. Added some tests that had become possible by doing so.**

This repository contains two iOS projects for the assignment:

- `Places`: a new SwiftUI app that fetches locations, displays them, allows custom locations, and opens Wikipedia for selected coordinates.
- `Wikipedia`: a modified version of the Wikimedia iOS app that can open the Places tab for a coordinate received through a custom URL scheme.

## Projects

### Places

See [`Places/README.md`](Places/README.md) for features, architecture, testing, accessibility notes, and how to run the app.

### Wikipedia

The original Wikimedia README is kept in [`Wikipedia/README.md`](Wikipedia/README.md).

Assignment-specific Wikipedia changes:

- Added support for the custom URL scheme:
  `wikipedia-places://openPlace?lat=<latitude>&long=<longitude>`
- The app opens the Places tab and positions the map around the provided coordinate.
- Existing `wikipedia://places` behavior was kept working.



Frans Glorie, 2026-09-04
