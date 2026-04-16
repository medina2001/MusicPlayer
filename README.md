# MusicPlayer — iOS

iOS app that lets users search for songs using the iTunes Search API, play previews, and browse album details.

---
## Demonstration
| Songs | Player | More Options | Album |
| --- | --- | --- | --- |
| <img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 - 2026-04-16 at 11 56 22" src="https://github.com/user-attachments/assets/c92e1810-ff0d-4bfb-b247-120f97372426" /> | <img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 - 2026-04-16 at 11 56 28" src="https://github.com/user-attachments/assets/55ab88da-3723-479e-82ff-5c2f6e57cf3e" /> | <img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 - 2026-04-16 at 11 56 34" src="https://github.com/user-attachments/assets/98d5620c-8cfb-4f15-b62e-b7c2545ccea2" /> | <img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 - 2026-04-16 at 11 56 39" src="https://github.com/user-attachments/assets/6b308e03-e910-4e17-9268-0bd8f2ee526a" /> |

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
