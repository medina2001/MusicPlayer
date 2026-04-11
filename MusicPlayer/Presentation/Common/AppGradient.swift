//
//  AppGradient.swift
//  MusicPlayer
//
//  Created by Gabriel Maciel on 11/04/26.
//

import SwiftUI

extension LinearGradient {
    static let appBackground = LinearGradient(
        colors: [.brand, .black, .black],
        startPoint: .topTrailing,
        endPoint: .bottomLeading
    )
}
