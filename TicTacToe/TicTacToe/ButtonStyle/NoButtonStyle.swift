//
//  NoButtonStyle.swift
//  TicTacToe
//
//  Created by Aleksandr on 16.08.2022.
//

import SwiftUI

struct NoButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

extension ButtonStyle where Self == NoButtonStyle {
    static var none: NoButtonStyle {
        NoButtonStyle()
    }
}
