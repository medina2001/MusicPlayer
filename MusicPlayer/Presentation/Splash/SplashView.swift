//
//  SplashView.swift
//  MusicPlayer
//
//  Created by Gabriel Maciel on 11/04/26.
//

import SwiftUI

struct SplashView: View {
    @Environment(DependencyContainer.self) private var container

    @State private var navigateToSongs = false
    @State private var recentSongs: [Song] = []

    var body: some View {
        NavigationStack {
            splashContent
                .navigationDestination(isPresented: $navigateToSongs) {
                    // TODO: Replace with SongsView(recentSongs: recentSongs) in task 11
                    Text("Songs Screen")
                }
        }
        .task {
            await loadRecentSongs()
        }
    }

    private var splashContent: some View {
        ZStack(alignment: .center) {
            LinearGradient.appBackground
                .ignoresSafeArea()
            
            Image(.musicalNote)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
        }
    }

    private func loadRecentSongs() async {
        do {
            recentSongs = try await container.recentSongsRepository.fetchRecentSongs()
        } catch {
            print("SplashView: failed to fetch recent songs — \(error)")
            recentSongs = []
        }
        navigateToSongs = false
    }
}
