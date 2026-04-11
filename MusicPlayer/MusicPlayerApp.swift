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
    @State private var isReady = false

    var body: some Scene {
        WindowGroup {
            if let container {
                NavigationStack {
                    if isReady {
                        SongsView()
                    } else {
                        SplashView(onReady: { isReady = true })
                    }
                }
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
            }
        }
    }
}
