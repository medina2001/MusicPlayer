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
                // TODO: Replace with SplashView() in task 9
                Text("Loading...")
                    .environment(container)
            } else {
                ProgressView()
            }
        }
        .modelContainer(for: RecentSongRecord.self) { result in
            switch result {
            case .success(let modelContainer):
                container = DependencyContainer(modelContext: modelContainer.mainContext)
            case .failure(let error):
                print("ModelContainer failed: \(error)")
                // TODO: Handle gracefully in task 9
            }
        }
    }
}
