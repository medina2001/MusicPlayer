//
//  ViewState.swift
//  MusicPlayer
//
//  Created by Gabriel Maciel on 11/04/26.
//

enum ViewState<T> {
    case idle
    case loading
    case loaded(T)
    case error(AppError)
}

extension ViewState: Equatable where T: Equatable {}
