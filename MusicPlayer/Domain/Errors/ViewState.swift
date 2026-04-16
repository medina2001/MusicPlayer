//
//  ViewState.swift
//  MusicPlayer
//
//  Created by Gabriel Maciel on 11/04/26.
//

enum ViewState<T> {
    case loading
    case loaded(T)
    case error(AppError)
}
