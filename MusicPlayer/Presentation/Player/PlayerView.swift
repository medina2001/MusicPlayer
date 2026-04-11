//
//  PlayerView.swift
//  MusicPlayer
//
//  Created by Gabriel Maciel on 11/04/26.
//

import SwiftUI

struct PlayerView: View {
    let song: Song

    var body: some View {
        Text(song.title)
            .navigationTitle(song.title)
    }
}
