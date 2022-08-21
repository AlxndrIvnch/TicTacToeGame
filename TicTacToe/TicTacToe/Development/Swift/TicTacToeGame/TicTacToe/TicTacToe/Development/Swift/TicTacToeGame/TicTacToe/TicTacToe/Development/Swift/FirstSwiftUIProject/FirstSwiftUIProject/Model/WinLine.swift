//
//  WinLine.swift
//  FirstSwiftUIProject
//
//  Created by Aleksandr on 16.08.2022.
//

enum WinLine: Equatable {
    case row(number: Int)
    case column(number: Int)
    case diagonal(isReversed: Bool)
}
