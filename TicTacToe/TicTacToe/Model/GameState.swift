//
//  GameState.swift
//  TicTacToe
//
//  Created by Aleksandr on 18.08.2022.
//

enum GameState: Equatable {
    case started
    case running(turn: Symbol)
    case botMoving
    case ended(GameEnd)
    
}
