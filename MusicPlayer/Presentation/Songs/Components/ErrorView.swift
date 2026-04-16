//
//  ErrorView.swift
//  MusicPlayer
//
//  Created by Gabriel Maciel on 16/04/26.
//

import SwiftUI

struct ErrorView: View {
    let error: AppError
    let tryAgain: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            VStack(spacing: 8) {
                Text("Couldn't Load Songs")
                    .font(.headline)
                Text(error.localizedDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            Button {
                tryAgain()
            } label: {
                Label("Try Again", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.borderedProminent)
            
            Spacer()
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
