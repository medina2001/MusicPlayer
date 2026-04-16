# MusicPlayer — iOS

iOS app that lets users search for songs using the iTunes Search API, play previews, and browse album details.

---

## Features

- Song search via iTunes API
- Paginated results
- Song preview player
- Album screen
- Bottom sheet with more options
- Offline cache with SwiftData
- Recently played songs on the home screen

---

## Tech Stack

- Swift 6
- SwiftUI
- Swift Concurrency (async/await)
- SwiftData
- MVVM
- XCTest

---

## Architecture

The project follows MVVM. Networking is abstracted behind protocols, so the API implementation can be swapped out without touching other layers. The goal was to keep things simple, testable, and easy to follow. This patterns works fine with this project because of the few possible flows and the way the states are handled on the application.

---

## Running the Project

1. Clone the repository
2. Open `MusicPlayer.xcodeproj` in Xcode
3. Run on a simulator or iPhone (iOS 17+)

No external dependencies or setup required.
If any error appears on the Xcode project, might be related to the Team:
1 - Go to Target > Signing & Capabilities
2 - Change the Team for the configured account on your Xcode

---

## Tests

Unit tests cover ViewModel logic and networking behavior using XCTest.

---

## Notes

The focus was on clean architecture, good SwiftUI practices, and maintainable code. There are a few things I'd improve with more time, but the core experience is solid.
