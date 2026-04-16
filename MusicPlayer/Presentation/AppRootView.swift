//
//  AppRootView.swift
//  MusicPlayer
//
//  Created by Codex on 16/04/26.
//

import SwiftUI

struct AppRootView: View {
    let container: DependencyContainer

    @State private var router = AppRouter()

    var body: some View {
        NavigationStack {
            SongsView(container: container, router: router)
                .navigationDestination(
                    item: Binding(
                        get: { router.playerContext },
                        set: { newValue in
                            if newValue == nil {
                                router.dismissPlayer()
                            }
                        }
                    )
                ) { playerContext in
                    PlayerView(
                        container: container,
                        router: router,
                        playerContext: playerContext
                    )
                }
                .navigationDestination(
                    item: Binding(
                        get: { router.albumRoute },
                        set: { newValue in
                            if newValue == nil {
                                router.dismissAlbum()
                            }
                        }
                    )
                ) { route in
                    AlbumView(
                        collectionId: route.collectionId,
                        container: container
                    ) { song, queue in
                        router.presentPlayer(song: song, queue: queue)
                        router.dismissAlbum()
                    }
                }
        }
        .environment(container)
        .environment(router)
    }
}
