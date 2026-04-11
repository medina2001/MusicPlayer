//
//  SplashView.swift
//  MusicPlayer
//
//  Created by Gabriel Maciel on 11/04/26.
//

import SwiftUI

struct SplashView: View {
    @Environment(DependencyContainer.self) private var container

    let onReady: () -> Void

    var body: some View {
        ZStack(alignment: .center) {
            LinearGradient.appBackground
                .ignoresSafeArea()

            Image(.musicalNote)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
        }
        .navigationBarBackButtonHidden(true)
        .task {
            await loadRecentSongs()
        }
    }

    private func loadRecentSongs() async {
        do {
            _ = try await container.recentSongsRepository.fetchRecentSongs()
        } catch {
            print("SplashView: failed to fetch recent songs — \(error)")
        }
        onReady()
    }
}
