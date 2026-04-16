//
//  MusicPlayerApp.swift
//  MusicPlayer
//
//  Created by Gabriel Maciel on 11/04/26.
//

import SwiftUI
import SwiftData

@main
struct MusicPlayerApp: App {
    @State private var container: DependencyContainer?

    var body: some Scene {
        WindowGroup {
            if let container {
                AppRootView(container: container)
            } else {
                ProgressView()
            }
        }
        .modelContainer(for: RecentSongRecord.self) { result in
            switch result {
            case .success(let modelContainer):
                container = DependencyContainer(modelContext: modelContainer.mainContext)
            case .failure:
                break
            }
        }
    }
}
